import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/quest/interview.dart';

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

  final Color maroon = const Color.fromARGB(255, 139, 58, 58);

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _extract(widget.ocrText);
  }

  void _extract(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final line in lines) {
      final l = line.toLowerCase();

      if (l.contains('government') ||
          l.contains('unique') ||
          l.contains('authority') ||
          l.contains('aadhaar') ||
          l.contains('uidai') ||
          l.contains('enrollment')) continue;

      if (!RegExp(r'^[A-Za-z .]+$').hasMatch(line)) continue;
      if (line.split(' ').length < 2) continue;

      nameCtrl.text = line;
      break;
    }

    final dobMatch = RegExp(r'\b\d{1,2}[\s\/\-]\d{1,2}[\s\/\-]\d{4}\b')
        .firstMatch(text);

    if (dobMatch != null) {
      dobCtrl.text = dobMatch.group(0)!;
      final year = int.parse(dobCtrl.text.split(RegExp(r'[\s\/\-]')).last);
      ageCtrl.text = (DateTime.now().year - year).toString();
    }

    if (text.toLowerCase().contains('female')) {
      genderCtrl.text = 'Female';
    } else if (text.toLowerCase().contains('male')) {
      genderCtrl.text = 'Male';
    }

    addressCtrl.text = lines.skipWhile((l) => !l.contains('C/O')).join('\n');
  }

  Future<void> _saveProfileAndContinue() async {
    final authRepository = AuthRepository();
    final phoneNumber = await authRepository.getStoredPhoneNumber();

    if (phoneNumber == null) return;

    final profileRepository = ProfileRepository();

    await profileRepository.saveOcrData(
      phoneNumber: phoneNumber,
      name: nameCtrl.text,
      dateOfBirth: dobCtrl.text,
      age: int.tryParse(ageCtrl.text),
      gender: genderCtrl.text,
      address: addressCtrl.text,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InterviewQuestionsPage()),
    );
  }

  Widget _field(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: c,
        enabled: isEditing,
        maxLines: max,
        cursorColor: maroon,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: maroon),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ SAME GRADIENT APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "User Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: maroonGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? "Done" : "Edit",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _field("Name", nameCtrl),
                    _field("DOB / YOB", dobCtrl),
                    _field("Age", ageCtrl),
                    _field("Gender", genderCtrl),
                    _field("Address", addressCtrl, max: 6),
                  ],
                ),
              ),
            ),

            // ✅ SAME MAROON GRADIENT BUTTON
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: maroonGradient,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: ElevatedButton(
                onPressed: _saveProfileAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Confirm & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}