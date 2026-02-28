import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final Color maroon = const Color(0xFF800000);

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

    // ================= NAME =================
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

    // ================= DOB =================
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

    // -------- Fallback: YOB --------
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

    // ================= GENDER =================
    final lowerText = text.toLowerCase();
    if (RegExp(r'\bfemale\b').hasMatch(lowerText)) {
      genderCtrl.text = 'Female';
    } else if (RegExp(r'\bmale\b').hasMatch(lowerText)) {
      genderCtrl.text = 'Male';
    }

    // ================= ADDRESS =================
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

  // ================= NEW: SAVE PROFILE + NAVIGATE =================
  Future<void> _saveProfileAndContinue() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

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

    // Retry saving up to 3 times on transient failures
    var result;
    for (int attempt = 1; attempt <= 3; attempt++) {
      result = await profileRepository.saveOcrData(
        phoneNumber: phoneNumber,
        name: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
        dateOfBirth: dobCtrl.text.isNotEmpty ? dobCtrl.text : null,
        age: ageInt,
        gender: genderCtrl.text.isNotEmpty ? genderCtrl.text : null,
        address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
      );
      if (result != null) break;
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InterviewQuestionsPage()),
    );
    setState(() => _isSaving = false);
  }

  // =================== TEXTFIELD DESIGN ===================
  Widget _field(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: c,
        enabled: isEditing,
        maxLines: max,
        cursorColor: maroon,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: maroon,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withOpacity(0.5), width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withOpacity(0.3), width: 1.2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? "Done" : "Edit",
              style: const TextStyle(color: Colors.black),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfileAndContinue,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Confirm & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
