import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'aadhaar_scan_screen.dart';

class AadhaarTestLauncher extends StatefulWidget {
  const AadhaarTestLauncher({Key? key}) : super(key: key);

  @override
  State<AadhaarTestLauncher> createState() => _AadhaarTestLauncherState();
}

class _AadhaarTestLauncherState extends State<AadhaarTestLauncher> {
  final FlutterTts flutterTts = FlutterTts();

  void _speakText(String text, String languageCode) async {
    if (languageCode == 'ml') {
      await flutterTts.setLanguage("ml-IN");
    } else {
      await flutterTts.setLanguage("en-US");
    }
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('aadhaarVerification')),
        backgroundColor: const Color.fromARGB(255, 109, 7, 7),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: () => _speakText(
                lang.translate('verifyIdentityDesc'), lang.languageCode),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF800000),
            ),
          ),
        ],
      ),
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
              "Community Voice",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                lang.translate('verifyIdentityDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AadhaarScanScreen(),
                  ),
                );

                // If user confirmed scan, navigate to HomePage
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
              icon: const Icon(Icons.camera_alt),
              label: Text(lang.translate('camera')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 109, 7, 7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
