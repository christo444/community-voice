import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'aadhaar_scan_controller_screen.dart';
import 'aadhaar_data.dart';

class AadhaarScanScreen extends StatefulWidget {
  final AadhaarData? aadhaarData;

  const AadhaarScanScreen({super.key, this.aadhaarData});

  @override
  State<AadhaarScanScreen> createState() => _AadhaarScanScreenState();
}

class _AadhaarScanScreenState extends State<AadhaarScanScreen> {
  CameraController? _cameraController;
  bool _isReady = false;
  bool _isProcessing = false;

  late AadhaarData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.aadhaarData ?? AadhaarData();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() => _isReady = true);
  }

  Future<void> _processImage(File file) async {
    setState(() => _isProcessing = true);

    final recognizer = TextRecognizer();
    final input = InputImage.fromFile(file);
    final result = await recognizer.processImage(input);
    recognizer.close();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AadhaarScanControllerScreen(
          ocrText: result.text,
          aadhaarData: _data,
        ),
      ),
    );

    setState(() => _isProcessing = false);
  }

  Future<void> _captureFromCamera() async {
    final image = await _cameraController!.takePicture();
    await _processImage(File(image.path));
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _processImage(File(picked.path));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ===== Gradient Button Widget (Reusable) =====
  Widget _gradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 139, 58, 58),
            Color.fromARGB(255, 74, 14, 26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== Gradient AppBar =====
      appBar: AppBar(
        title: const Text(
          "Scan Aadhaar",
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
      ),

      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CameraPreview(_cameraController!),
                ),

                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _gradientButton(
                          icon: Icons.camera_alt,
                          text: "Scan",
                          onPressed: _captureFromCamera,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _gradientButton(
                          icon: Icons.photo,
                          text: "Gallery",
                          onPressed: _pickFromGallery,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
