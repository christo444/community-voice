import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarTestLauncher extends StatelessWidget {
  const AadhaarTestLauncher({Key? key}) : super(key: key);

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ GRADIENT APPBAR (MATCHES ALL OTHER SCREENS)
      appBar: AppBar(
        title: Text(
          lang.translate('aadhaarVerification'),
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor: Color.fromARGB(255, 139, 58, 58),
            ),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card,
                size: 90,
                color: Color.fromARGB(255, 139, 58, 58),
              ),

              const SizedBox(height: 30),

              const Text(
                "Community Voice",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Please verify your identity with Aadhaar to access government schemes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 50),

              // ✅ GRADIENT BUTTON (MATCHES SCAN & DETAILS)
              Container(
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
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
                  label: Text(
                    lang.translate('camera'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
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
      ),
    );
  }
}