import 'package:flutter/material.dart';
import 'aadhaar_data.dart';
import 'aadhaar_details_screen.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarScanControllerScreen extends StatefulWidget {
  final String ocrText;
  final AadhaarData aadhaarData;

  const AadhaarScanControllerScreen({
    Key? key,
    required this.ocrText,
    required this.aadhaarData,
  }) : super(key: key);

  @override
  State<AadhaarScanControllerScreen> createState() =>
      _AadhaarScanControllerScreenState();
}

class _AadhaarScanControllerScreenState
    extends State<AadhaarScanControllerScreen> {
  @override
  void initState() {
    super.initState();
    _processOCR();
  }

  void _processOCR() {
    final text = widget.ocrText.toLowerCase();

    // ---------- FRONT SIDE ----------
    if (text.contains('dob') || text.contains('date of birth')) {
      widget.aadhaarData.frontOcrText = widget.ocrText;

      if (widget.aadhaarData.name.isEmpty) {
        final nameMatch =
            RegExp(r'^[A-Za-z .]{3,}$', multiLine: true)
                .firstMatch(widget.ocrText);
        if (nameMatch != null) {
          widget.aadhaarData.name = nameMatch.group(0)!.trim();
        }
      }

      if (widget.aadhaarData.dob.isEmpty) {
        final dobMatch = RegExp(
          r'\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}\b',
        ).firstMatch(widget.ocrText);

        if (dobMatch != null) {
          widget.aadhaarData.dob = dobMatch.group(0)!;
          final year =
              int.parse(widget.aadhaarData.dob.substring(6));
          widget.aadhaarData.age =
              (DateTime.now().year - year).toString();
        }
      }

      if (widget.aadhaarData.gender.isEmpty) {
        if (text.contains('female')) widget.aadhaarData.gender = 'Female';
        if (text.contains('male')) widget.aadhaarData.gender = 'Male';
      }
    }

    // ---------- BACK SIDE ----------
    if (RegExp(r'\b\d{6}\b').hasMatch(widget.ocrText)) {
      widget.aadhaarData.backOcrText = widget.ocrText;
      widget.aadhaarData.address = widget.ocrText;
    }

    // ---------- FINAL DECISION ----------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.aadhaarData.hasFront && widget.aadhaarData.hasBack) {
        // ✅ MERGE OCR TEXTS
        final combinedOcrText =
            '${widget.aadhaarData.frontOcrText}\n${widget.aadhaarData.backOcrText}';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AadhaarDetailsScreen(ocrText: combinedOcrText),
          ),
        );
        return;
      }

      final msg = widget.aadhaarData.hasFront
          ? 'Front side scanned.\nPlease scan the BACK side of Aadhaar.'
          : 'Back side scanned.\nPlease scan the FRONT side of Aadhaar.';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AadhaarScanScreen(aadhaarData: widget.aadhaarData),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}