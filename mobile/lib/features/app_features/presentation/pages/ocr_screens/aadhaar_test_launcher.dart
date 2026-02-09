import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarTestLauncher extends StatelessWidget {
  const AadhaarTestLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== GRADIENT APP BAR =====
      appBar: AppBar(
        title: const Text(
          "Aadhaar Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8B3A3A),
                Color(0xFF4A0E1A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // ===== BODY =====
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card,
              size: 80,
              color: Color.fromARGB(255, 109, 7, 7),
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
                  color: Color.fromARGB(255, 68, 67, 67),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ===== GRADIENT START AADHAAR SCAN BUTTON =====
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B3A3A),
                      Color(0xFF4A0E1A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Start Aadhaar Scan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
