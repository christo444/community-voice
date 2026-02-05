import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AadhaarScanScreen extends StatefulWidget {
  const AadhaarScanScreen({Key? key}) : super(key: key);

  @override
  State<AadhaarScanScreen> createState() => _AadhaarScanScreenState();
}

class _AadhaarScanScreenState extends State<AadhaarScanScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isEditing = false;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController yobCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _captureAndProcess() async {
    setState(() => _isProcessing = true);

    final XFile image = await _cameraController.takePicture();
    final inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    _extractDetails(recognizedText.text);

    await File(image.path).delete();
    setState(() => _isProcessing = false);
  }

  // =========================================================
  // ================= EXTRACTION LOGIC ======================
  // =========================================================
  void _extractDetails(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // ---------------- NAME (AADHAAR-SPECIFIC & RELIABLE) ----------------
    // Strategy:
    // 1. Ignore "To"
    // 2. Ignore local language IF English name exists
    // 3. Ignore D/O, S/O, W/O lines
    // 4. Pick first clean English name

    String? detectedEnglishName;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Skip non-name lines
      if (lower == 'to') continue;
      if (lower.contains(RegExp(r'\b(s/o|d/o|w/o|c/o)\b'))) continue;
      if (lower.contains(RegExp(
          r'government|india|authority|aadhaar|female|male|year|birth'))) {
        continue;
      }
      if (line.contains(RegExp(r'\d'))) continue;
      if (line.length < 3) continue;

      // Prefer ENGLISH name
      if (RegExp(r'^[A-Za-z .]+$').hasMatch(line)) {
        detectedEnglishName = line;
        break;
      }
    }

    if (detectedEnglishName != null) {
      nameCtrl.text = detectedEnglishName;
    }

    // ---------------- YEAR OF BIRTH ----------------
    final yobRegex = RegExp(
      r'(year\s*of\s*birth|yob|dob)[^\d]*(\d{4})',
      caseSensitive: false,
    );

    final yobMatch = yobRegex.firstMatch(text);
    if (yobMatch != null) {
      yobCtrl.text = yobMatch.group(2)!;
      ageCtrl.text =
          (DateTime.now().year - int.parse(yobCtrl.text)).toString();
    }

    // ---------------- GENDER ----------------
    final lowerText = text.toLowerCase();
    if (lowerText.contains('female')) {
      genderCtrl.text = 'Female';
    } else if (lowerText.contains('male')) {
      genderCtrl.text = 'Male';
    }

    // ---------------- ADDRESS (PIN-BASED, AADHAAR-PROVEN) ----------------
    List<String> addressBuffer = [];
    int pinIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      if (RegExp(r'\b\d{6}\b').hasMatch(lines[i])) {
        pinIndex = i;
        break;
      }
    }

    if (pinIndex != -1) {
      for (int i = pinIndex - 3; i <= pinIndex; i++) {
        if (i < 0 || i >= lines.length) continue;

        final line = lines[i].toLowerCase();
        if (line.contains(RegExp(
            r'uidai|government|aadhaar|qr|unique identification'))) {
          continue;
        }

        addressBuffer.add(lines[i]);
      }
    }

    addressCtrl.text = addressBuffer.join(', ');
  }

  // =========================================================

  @override
  void dispose() {
    _cameraController.dispose();
    nameCtrl.dispose();
    yobCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Aadhaar")),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  flex: 3,
                  child: CameraPreview(_cameraController),
                ),
                Expanded(
                  flex: 4,
                  child: _isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : _detailsSection(),
                ),
                _captureButton(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _captureButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _captureAndProcess,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan Aadhaar"),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _detailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Extracted Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  child: Text(_isEditing ? "Done" : "Edit"),
                )
              ],
            ),
            const SizedBox(height: 12),
            _field("Name", nameCtrl),
            _field("Year of Birth", yobCtrl,
                keyboard: TextInputType.number),
            _field("Age", ageCtrl, keyboard: TextInputType.number),
            _field("Gender", genderCtrl),
            _field("Address", addressCtrl, maxLines: 3),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "name": nameCtrl.text,
                        "yob": yobCtrl.text,
                        "age": ageCtrl.text,
                        "gender": genderCtrl.text,
                        "address": addressCtrl.text,
                      });
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
