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
      backgroundColor: Colors.white,

      // ✅ GRADIENT APPBAR (MATCHES OTHER SCREENS)
      appBar: AppBar(
        title: const Text(
          "Scan Aadhaar",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
      ),

      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: CameraPreview(_cameraController!),
                  ),
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
                      // ✅ GRADIENT SCAN BUTTON
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: maroonGradient,
                            borderRadius:
                                BorderRadius.all(Radius.circular(14)),
                          ),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            label: const Text(
                              "Scan",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: _captureFromCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ✅ OUTLINED GALLERY BUTTON (MAROON BORDER)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo,
                              color: Color.fromARGB(255, 139, 58, 58)),
                          label: const Text(
                            "Gallery",
                            style: TextStyle(
                                color:
                                    Color.fromARGB(255, 139, 58, 58)),
                          ),
                          onPressed: _pickFromGallery,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color.fromARGB(255, 139, 58, 58),
                                width: 2),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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