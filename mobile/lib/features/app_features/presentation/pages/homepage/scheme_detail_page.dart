import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:community_voice/domain/repository/scheme_repository.dart';
import 'package:community_voice/domain/model/scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class SchemeDetailPage extends StatefulWidget {
  final String schemeId;
  final String name;
  final String description;

  const SchemeDetailPage({
    super.key,
    required this.schemeId,
    required this.name,
    required this.description,
  });

  @override
  State<SchemeDetailPage> createState() => _SchemeDetailPageState();
}

class _SchemeDetailPageState extends State<SchemeDetailPage> {
  // TTS instance for reading the page
  final FlutterTts flutterTts = FlutterTts();
  // Track if TTS is currently speaking
  bool isSpeaking = false;

  // Repository and state
  final SchemeRepository _schemeRepository = SchemeRepository();
  SchemeDetails? _schemeDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadSchemeDetails();
  }

  // Load complete scheme details
  Future<void> _loadSchemeDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final details = await _schemeRepository.getSchemeDetails(widget.schemeId);

      setState(() {
        _schemeDetails = details;
        _isLoading = false;
      });

      if (details == null) {
        setState(() {
          _errorMessage = 'Failed to load scheme details';
        });
      }
    } catch (e) {
      print('Error loading scheme details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // Initialize TTS
  Future<void> _initTts() async {
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
      ${widget.description}
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
      appBar: const CustomAppBar(title: "Scheme Details"),
      backgroundColor: const Color.fromARGB(255, 237, 233, 233),
      body: Stack(
        children: [
          // Main scrollable content
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF800000),
                  ),
                )
              : _errorMessage != null || _schemeDetails == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage ?? 'Scheme not found',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                            ),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
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
                          if (widget.description.isNotEmpty) ...[
                            const SectionHeading(text: "Description"),
                            const SectionSpacer(height: 12),
                            _buildInfoCard(widget.description),
                            const SectionSpacer(height: 20),
                          ],

                          // Benefits Section
                          if (_schemeDetails!.benefits != null &&
                              _schemeDetails!.benefits!.isNotEmpty) ...[
                            const SectionHeading(text: "Benefits"),
                            const SectionSpacer(height: 12),
                            _buildInfoCard(_schemeDetails!.benefits!),
                            const SectionSpacer(height: 20),
                          ],

                          // Other sections can be added here as needed
                          const SectionSpacer(height: 32),
                        ],
                      ),
                    ),
          // Floating Voice button
          if (!_isLoading && _schemeDetails != null)
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

  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: GoogleFonts.openSans(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}