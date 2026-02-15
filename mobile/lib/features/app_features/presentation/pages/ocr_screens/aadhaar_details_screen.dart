import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/interview/questions.dart';

class AadhaarDetailsScreen extends StatefulWidget {
  final String ocrText;

  const AadhaarDetailsScreen({super.key, required this.ocrText});

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

      if (l == 'to') {
        continue;
      }
      if (l.contains('government') ||
          l.contains('unique') ||
          l.contains('authority') ||
          l.contains('aadhaar') ||
          l.contains('uidai') ||
          l.contains('enrollment')) {
        continue;
      }

      if (!RegExp(r'^[A-Za-z .]+$').hasMatch(line)) {
        continue;
      }
      if (line.split(' ').length < 2) {
        continue;
      }

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

        String cleaned = line.replaceFirst(
          RegExp(
            r'^(c/o|s/o|d/o|w/o)\s*[:\-]?\s*[A-Za-z .]+,?',
            caseSensitive: false,
          ),
          '',
        ).trim();

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

      final cleanedLine =
          line.replaceFirst(RegExp(r'^[A-Z]\s+'), '');

      addressLines.add(cleanedLine);

      if (RegExp(r'\b\d{6}\b').hasMatch(cleanedLine)) {
        break;
      }
    }

    addressCtrl.text = addressLines.join('\n');
  }

  // ================= FIELD =================
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
          labelStyle: TextStyle(color: maroon, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: maroon.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== GRADIENT APP BAR =====
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 139, 58, 58),
                Color.fromARGB(255, 74, 14, 26),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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

            // ===== GRADIENT CONFIRM BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 139, 58, 58),
                      Color.fromARGB(255, 74, 14, 26),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
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
                  onPressed: () {
                    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const QuestionnairePage(),
    ),
  );
},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
