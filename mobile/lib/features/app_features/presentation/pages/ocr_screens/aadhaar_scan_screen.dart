import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'aadhaar_scan_controller_screen.dart';
import 'aadhaar_data.dart';

class AadhaarScanScreen extends StatefulWidget {
  final AadhaarData? aadhaarData;

  const AadhaarScanScreen({Key? key, this.aadhaarData}) : super(key: key);

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
          aadhaarData: _data, // ✅ SAME OBJECT PASSED EVERY TIME
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
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _processImage(File(picked.path));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Aadhaar")),
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
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Scan"),
                          onPressed: _captureFromCamera,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text("Gallery"),
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