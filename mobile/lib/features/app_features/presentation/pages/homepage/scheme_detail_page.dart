import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: const CustomAppBar(title: "പദ്ധതി വിശദാംശങ്ങൾ"),
      backgroundColor: const Color.fromARGB(255, 237, 233, 233),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scheme Name Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DetailTitle(text: widget.name),
                  ),
                ),
                const SectionSpacer(height: 20),
                
                // Description Section
                const SectionHeading(text: "വിശദാംശങ്ങൾ:"),
                const SectionSpacer(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // ===== UI DESIGNER: CUSTOMIZE DESCRIPTION TEXT BELOW =====
                    child: Text(
                      widget.description,
                      style: GoogleFonts.openSans(
                        fontSize: 16, // ✅ CUSTOMIZABLE: 15.5 → 16 (Larger)
                        height: 1.6, // ✅ CUSTOMIZABLE: Line spacing
                        color: Colors.black87, // ✅ CUSTOMIZABLE: Dark black
                        fontWeight: FontWeight.w500, // ✅ CUSTOMIZABLE: Semi-bold
                      ),
                    ),
                    // ===== END CUSTOMIZATION ZONE =====
                  ),
                ),
                const SectionSpacer(height: 20),
                
                // How to Apply Section
                const SectionHeading(text: "എങ്ങനെ അപേക്ഷിക്കാം:"),
                const SectionSpacer(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // ===== UI DESIGNER: CUSTOMIZE HOW-TO-APPLY TEXT BELOW =====
                    child: Text(
                      widget.howToApply,
                      style: GoogleFonts.openSans(
                        fontSize: 16, // ✅ CUSTOMIZABLE: 15.5 → 16 (Larger)
                        height: 1.7, // ✅ CUSTOMIZABLE: Line spacing
                        color: Colors.black87, // ✅ CUSTOMIZABLE: Dark black
                        fontWeight: FontWeight.w400, // ✅ CUSTOMIZABLE: Regular weight
                      ),
                    ),
                    // ===== END CUSTOMIZATION ZONE =====
                  ),
                ),
                const SectionSpacer(height: 32),
              ],
            ),
          ),
          // Floating Voice button at top right
          Positioned(
            top: 16,
            right: 16,
            child: FloatingVoiceButton(
              isSpeaking: isSpeaking,
              onPressed: _toggleSpeech,
            ),
          ),
        ],
      ),
    );
  }
}