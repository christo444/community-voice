// ignore_for_file: prefer_const_constructors

import 'package:community_voice/core/theme/colors.dart';
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

  @override
  void dispose() {
    flutterTts.stop(); // Stop speech when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("സർക്കാർ പദ്ധതികൾ"),
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Heading Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "നിങ്ങൾക്ക് അർഹതയുള്ള പദ്ധതികൾ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
          ),
          // List of Schemes
          Expanded(
            child: ListView.builder(
              itemCount: dummySchemes.length,
              itemBuilder: (context, index) {
                final scheme = dummySchemes[index];
                return ListTile(
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
                  title: Text(
                    scheme['name']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(scheme['description']!),
                  trailing: IconButton(
                    icon: Icon(
                      speakingIndex == index ? Icons.stop : Icons.volume_up,
                      color: AppColors.maroon,
                      size: 30,
                    ),
                    onPressed: () {
                      // Toggle speech for this scheme
                      _toggleSpeak(index, scheme['name']!, scheme['description']!);
                    },
                  ),
                  tileColor: AppColors.white,
                  contentPadding: EdgeInsets.all(16),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}