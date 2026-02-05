// ignore_for_file: prefer_const_constructors

import 'package:community_voice/features/app_features/presentation/pages/ocr_screens/aadhaar_test_launcher.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const CommunityVoice());
}

class CommunityVoice extends StatelessWidget {
  const CommunityVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AadhaarTestLauncher(),
    );
  }
}
