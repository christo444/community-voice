import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:community_voice/features/app_features/presentation/pages/quest/interview.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import '../../../../../domain/repository/profile_repository.dart';
import '../../../../../domain/repository/auth_repository.dart';

class AadhaarDetailsScreen extends StatefulWidget {
  final String ocrText;

  const AadhaarDetailsScreen({Key? key, required this.ocrText})
      : super(key: key);

  @override
  State<AadhaarDetailsScreen> createState() => _AadhaarDetailsScreenState();
}

class _AadhaarDetailsScreenState extends State<AadhaarDetailsScreen> {
  bool isEditing = false;

  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color maroon = Color.fromARGB(255, 139, 58, 58);

  @override
  void initState() {
    super.initState();
    _extract(widget.ocrText);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    dobCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  // ================= OCR LOGIC (UNCHANGED) =================
  void _extract(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final line in lines) {
      final l = line.toLowerCase();
      if (!RegExp(r'^[A-Za-z .]+$').hasMatch(line)) continue;
      if (line.split(' ').length < 2) continue;
      if (l.contains('aadhaar') || l.contains('government')) continue;
      nameCtrl.text = line;
      break;
    }

    final dobMatch =
        RegExp(r'\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}\b').firstMatch(text);

    if (dobMatch != null) {
      dobCtrl.text = dobMatch.group(0)!;
      final year =
          int.tryParse(dobCtrl.text.substring(dobCtrl.text.length - 4));
      if (year != null) {
        ageCtrl.text = (DateTime.now().year - year).toString();
      }
    }

    if (text.toLowerCase().contains("female")) {
      genderCtrl.text = "Female";
    } else if (text.toLowerCase().contains("male")) {
      genderCtrl.text = "Male";
    }

    if (lines.length > 4) {
      addressCtrl.text = lines.sublist(4).join("\n");
    }
  }

  // ================= SAVE LOGIC (UNCHANGED) =================
  Future<void> _saveProfileAndContinue() async {
    final authRepository = AuthRepository();
    final phoneNumber = await authRepository.getStoredPhoneNumber();

    if (phoneNumber == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? ageInt;
    if (ageCtrl.text.isNotEmpty) {
      ageInt = int.tryParse(ageCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    final profileRepository = ProfileRepository();

    final result = await profileRepository.saveOcrData(
      phoneNumber: phoneNumber,
      name: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
      dateOfBirth: dobCtrl.text.isNotEmpty ? dobCtrl.text : null,
      age: ageInt,
      gender: genderCtrl.text.isNotEmpty ? genderCtrl.text : null,
      address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
    );

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InterviewQuestionsPage()),
    );
  }

  // ================= TEXTFIELD =================
  Widget _field(String label, TextEditingController controller,
      {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        maxLines: max,
        cursorColor: maroon,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: maroon, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ GRADIENT APPBAR (MATCHES INTERVIEW)
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? "Done" : "Edit",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field("Name", nameCtrl),
          _field("DOB / YOB", dobCtrl),
          _field("Age", ageCtrl),
          _field("Gender", genderCtrl),
          _field("Address", addressCtrl, max: 6),
        ],
      ),

      // ✅ GRADIENT BUTTON (MATCHES INTERVIEW)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: maroonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton(
            onPressed: _saveProfileAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Confirm & Continue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}