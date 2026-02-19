import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarTestLauncher extends StatelessWidget {
  const AadhaarTestLauncher({Key? key}) : super(key: key);

  /// SAME GLOBAL GRADIENT
  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color maroon = Color.fromARGB(255, 139, 58, 58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ ADDED — fixes black background

      appBar: AppBar(
        title: const Text(
          "Aadhaar Verification",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card,
              size: 80,
              color: maroon,
            ),
            const SizedBox(height: 30),
            const Text(
              "Welcome to Community Voice",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Please verify your identity with Aadhaar to access government schemes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),

            /// GRADIENT BUTTON
            Container(
              decoration: BoxDecoration(
                gradient: maroonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AadhaarScanScreen(),
                    ),
                  );

                  if (result != null) {
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Start Aadhaar Scan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
