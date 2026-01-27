import 'package:community_voice/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SchemeDetailPage extends StatefulWidget {
  final String name;
  final String description;
  final String howToApply;

  const SchemeDetailPage({
    super.key,
    required this.name,
    required this.description,
    required this.howToApply,
  });

  @override
  State<SchemeDetailPage> createState() => _SchemeDetailPageState();
}

class _SchemeDetailPageState extends State<SchemeDetailPage> {
  // TTS instance for reading the page
  final FlutterTts flutterTts = FlutterTts();
  // Track if TTS is currently speaking
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Initialize TTS with Malayalam language
  Future<void> _initTts() async {
    await flutterTts.setLanguage("ml-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    
    // Listen to completion to update state
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  // Function to toggle speech - start or stop
  Future<void> _toggleSpeech() async {
    if (isSpeaking) {
      // If speaking, stop it
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      // If not speaking, start reading
      String pageContent = '''
      ${widget.name}. 
      വിശദാംശങ്ങൾ. ${widget.description}. 
      എങ്ങനെ അപേക്ഷിക്കാം. ${widget.howToApply}
      ''';
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.speak(pageContent);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("പദ്ധതി വിശദാംശങ്ങൾ"),
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.white,
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scheme Name
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Description Section
                const Text(
                  "വിശദാംശങ്ങൾ:", // Details
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                
                // How to Apply Section
                const Text(
                  "എങ്ങനെ അപേക്ഷിക്കാം:", // How to apply
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.howToApply,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Voice button at top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.maroon,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isSpeaking ? Icons.stop : Icons.volume_up,
                  color: AppColors.white,
                  size: 28,
                ),
                onPressed: _toggleSpeech,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
