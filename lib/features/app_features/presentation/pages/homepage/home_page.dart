// ignore_for_file: prefer_const_constructors

import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:community_voice/domain/repository/auth_repository.dart';
import 'package:community_voice/features/app_features/presentation/pages/auth/phone_input_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'scheme_detail_page.dart';

// Dummy data - temporary list of schemes for testing
// Later we'll replace this with real data from backend
final List<Map<String, String>> dummySchemes = [
  {
    'name': 'പെൻഷൻ യോജന',
    'description': 'വയോജനങ്ങൾക്കുള്ള പെൻഷൻ പദ്ധതി',
    'howToApply': 'നിങ്ങളുടെ പ്രദേശത്തെ താലൂക്ക് ഓഫീസിൽ പോയി അപേക്ഷിക്കുക. ആധാർ കാർഡും വയസ്സ് തെളിയിക്കുന്ന രേഖയും കൂടെ കൊണ്ടുപോകുക.',
  },
  {
    'name': 'വിദ്യാഭ്യാസ സഹായം',
    'description': 'കുട്ടികളുടെ വിദ്യാഭ്യാസത്തിനുള്ള സാമ്പത്തിക സഹായം',
    'howToApply': 'സ്കൂളിലൂടെ അപേക്ഷിക്കാം. വിദ്യാർത്ഥിയുടെ ബാങ്ക് അക്കൗണ്ട് വിശദാംശങ്ങളും വരുമാന സർട്ടിഫിക്കറ്റും ആവശ്യമാണ്.',
  },
  {
    'name': 'ആരോഗ്യ ഇൻഷുറൻസ്',
    'description': 'സൗജന്യ ആരോഗ്യ ഇൻഷുറൻസ് പദ്ധതി',
    'howToApply': 'അടുത്തുള്ള ആരോഗ്യ കേന്ദ്രത്തിൽ പോയി രജിസ്റ്റർ ചെയ്യുക. കുടുംബത്തിലെ എല്ലാവരുടെയും ആധാർ കാർഡുകൾ കൊണ്ടുവരിക.',
  },
];

// ===== UI DESIGNER: MAIN BACKGROUND COLOR =====
const Color mainBackgroundColor = Color.fromARGB(255, 253, 240, 213);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TTS instance - handles text-to-speech
  final FlutterTts flutterTts = FlutterTts();
  // Track which scheme is currently speaking (null if none)
  int? speakingIndex;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Initialize TTS with Malayalam language
  Future<void> _initTts() async {
    await flutterTts.setLanguage("ml-IN"); // Malayalam language
    await flutterTts.setSpeechRate(0.5); // Speed of speech (0.5 = slower, clear)
    await flutterTts.setVolume(1.0); // Volume (0.0 to 1.0)
    await flutterTts.setPitch(1.0); // Voice pitch
    
    // Listen to completion to update state
    flutterTts.setCompletionHandler(() {
      setState(() {
        speakingIndex = null;
      });
    });
  }

  // Function to toggle speech for a specific scheme
  Future<void> _toggleSpeak(int index, String name, String description) async {
    if (speakingIndex == index) {
      // If this scheme is speaking, stop it
      await flutterTts.stop();
      setState(() {
        speakingIndex = null;
      });
    } else {
      // Stop any current speech and start new one
      await flutterTts.stop();
      String textToSpeak = "$name. $description";
      setState(() {
        speakingIndex = index;
      });
      await flutterTts.speak(textToSpeak);
    }
  }

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'ലോഗ് ഔട്ട്',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
          content: const Text(
            'നിങ്ങൾക്ക് ലോഗ് ഔട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'റദ്ദാക്കുക',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.pop(dialogContext);
                
                // Perform logout
                final authRepository = AuthRepository();
                await authRepository.logout();
                
                if (!mounted) return;
                
                // Navigate to phone input page and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhoneInputPage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'ലോഗ് ഔട്ട്',
                style: TextStyle(
                  color: Color(0xFF800000),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop speech when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== APP BAR WITH MAROON GRADIENT =====
      appBar: AppBar(
        title: const Text(
          "സർക്കാർ പദ്ധതികൾ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 237, 233, 233), // ✅ USE COLOR CONSTANT
      body: Column(
        children: [
          // ===== PAGE HEADING WITH SAME BACKGROUND COLOR =====
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 237, 233, 233), // ✅ CHANGED: Gradient → Solid color
            ),
            // ===== UI DESIGNER: CUSTOMIZE HEADING TEXT COLOR BELOW =====
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                "നിങ്ങൾക്ക്  അർഹതയുള്ള  പദ്ധതികൾ",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 109, 7, 7),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // ===== END CUSTOMIZATION ZONE =====
          ),
          // List of Schemes with updated SchemeTile
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              itemCount: dummySchemes.length,
              itemBuilder: (context, index) {
                final scheme = dummySchemes[index];
                return SchemeTile(
                  name: scheme['name']!,
                  description: scheme['description']!,
                  onTap: () {
                    // Navigate to detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchemeDetailPage(
                          name: scheme['name']!,
                          description: scheme['description']!,
                          howToApply: scheme['howToApply']!,
                        ),
                      ),
                    );
                  },
                  trailing: VoiceButton(
                    isSpeaking: speakingIndex == index,
                    onPressed: () {
                      // Toggle speech for this scheme
                      _toggleSpeak(index, scheme['name']!, scheme['description']!);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}