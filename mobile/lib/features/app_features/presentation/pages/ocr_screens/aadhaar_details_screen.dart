import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'package:community_voice/features/app_features/presentation/pages/quest/interview.dart';

// ✅ ONLY NEW IMPORTS (added, nothing removed)
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

  /// SAME GLOBAL COLORS
  static const Color maroon = Color.fromARGB(255, 139, 58, 58);

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

      if (l == 'to') continue;
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

    for (final line in lines) {
      final l = line.toLowerCase();

      if (l.contains('dob') || l.contains('date of birth')) {
        final dateMatch = RegExp(
          r'\b\d{1,2}[\s\/\-]\d{1,2}[\s\/\-]\d{4}\b',
        ).firstMatch(line);

        if (dateMatch != null) {
          dobCtrl.text = dateMatch.group(0)!;

          final yearMatch =
              RegExp(r'\b(19|20)\d{2}\b').firstMatch(dobCtrl.text);

          if (yearMatch != null) {
            final year = int.parse(yearMatch.group(0)!);
            ageCtrl.text = (DateTime.now().year - year).toString();
          }
          break;
        }
      }
    }

    if (dobCtrl.text.isEmpty) {
      final yobMatch = RegExp(
        r'year\s*of\s*birth[:\s]*(\d{4})',
        caseSensitive: false,
      ).firstMatch(text);

      if (yobMatch != null) {
        dobCtrl.text = yobMatch.group(1)!;
        ageCtrl.text =
            (DateTime.now().year - int.parse(yobMatch.group(1)!)).toString();
      }
    }

    final lowerText = text.toLowerCase();
    if (RegExp(r'\bfemale\b').hasMatch(lowerText)) {
      genderCtrl.text = 'Female';
    } else if (RegExp(r'\bmale\b').hasMatch(lowerText)) {
      genderCtrl.text = 'Male';
    }

    List<String> addressLines = [];
    bool startCapture = false;

    for (final line in lines) {
      final l = line.toLowerCase();

      if (l.startsWith('c/o') ||
          l.startsWith('s/o') ||
          l.startsWith('d/o') ||
          l.startsWith('w/o')) {
        startCapture = true;

        String cleaned = line
            .replaceFirst(
              RegExp(
                r'^(c/o|s/o|d/o|w/o)\s*[:\-]?\s*[A-Za-z .]+,?',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

        if (cleaned.isNotEmpty) {
          addressLines.add(cleaned);
        }
        continue;
      }

      if (!startCapture) continue;

      if (l.contains('vtc') ||
          l.contains('po') ||
          l.contains('sub district') ||
          l.contains('uidai') ||
          l.contains('government') ||
          l.contains('aadhaar')) {
        continue;
      }

      final cleanedLine = line.replaceFirst(RegExp(r'^[A-Z]\s+'), '');

      addressLines.add(cleanedLine);

      if (RegExp(r'\b\d{6}\b').hasMatch(cleanedLine)) {
        break;
      }
    }

    addressCtrl.text = addressLines.join('\n');
  }

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
          content: Text('Failed to save profile. Please try again.'),
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
          labelStyle: const TextStyle(
            color: maroon,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: maroon, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ ONLY CHANGE

      appBar: AppBar(
        title: const Text("User Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    _field("Address", addressCtrl, max: 8),
                  ],
                ),
              ),
            ),

            /// GRADIENT BUTTON
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: maroonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                onPressed: _saveProfileAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Confirm & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
