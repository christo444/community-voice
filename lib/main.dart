// ignore_for_file: prefer_const_constructors

import 'package:community_voice/features/app_features/presentation/pages/screen.dart/aadhaar_test_launcher.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const CommunityVoice());
}

class CommunityVoice extends StatelessWidget {
  const CommunityVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 132, 192, 242),
        appBar: AppBar(
          title: const Text("Community Voice"),
          backgroundColor: Colors.red,
        ),

        // ✅ IMPORTANT: Builder gives correct Navigator context
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Community Voice",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AadhaarTestLauncher(),
                        ),
                      );

                      debugPrint("Aadhaar Scan Result: $result");
                    },
                    child: const Text("TEST Aadhaar Scan"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
