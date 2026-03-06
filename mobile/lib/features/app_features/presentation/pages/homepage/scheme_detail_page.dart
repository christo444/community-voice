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
      if (_schemeDetails != null) {
        String pageContent = '''
        ${widget.name}. 
        Description: ${_summarizeText(widget.description, 50)}. 
        Benefits: ${_schemeDetails!.benefits != null ? _summarizeText(_schemeDetails!.benefits!, 50) : 'Not specified'}.
        ''';
        setState(() {
          isSpeaking = true;
        });
        await flutterTts.speak(pageContent);
      }
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

                          // Description Section (Summarized)
                          if (widget.description.isNotEmpty) ...[
                            const SectionHeading(text: "Description"),
                            const SectionSpacer(height: 12),
                            _buildInfoCard(_summarizeText(widget.description, 200)),
                            const SectionSpacer(height: 20),
                          ],

                          // Benefits Section (Summarized)
                          if (_schemeDetails!.benefits != null &&
                              _schemeDetails!.benefits!.isNotEmpty) ...[
                            const SectionHeading(text: "Benefits"),
                            const SectionSpacer(height: 12),
                            _buildInfoCard(_summarizeText(_schemeDetails!.benefits!, 200)),
                            const SectionSpacer(height: 20),
                          ],

                          // Eligibility Section
                          if (_schemeDetails!.eligibility.isNotEmpty) ...[
                            const SectionHeading(text: "Eligibility Criteria"),
                            const SectionSpacer(height: 12),
                            _buildBulletList(_schemeDetails!.eligibility),
                            const SectionSpacer(height: 20),
                          ],

                          // Exclusions Section
                          if (_schemeDetails!.exclusions.isNotEmpty) ...[
                            const SectionHeading(text: "Exclusions"),
                            const SectionSpacer(height: 12),
                            _buildBulletList(_schemeDetails!.exclusions),
                            const SectionSpacer(height: 20),
                          ],

                          // Application Process Section
                          if (_schemeDetails!.applicationProcess.isNotEmpty) ...[
                            const SectionHeading(text: "Application Process"),
                            const SectionSpacer(height: 12),
                            _buildNumberedList(_schemeDetails!.applicationProcess),
                            const SectionSpacer(height: 20),
                          ],

                          // Documents Required Section
                          if (_schemeDetails!.documentsRequired.isNotEmpty) ...[
                            const SectionHeading(text: "Documents Required"),
                            const SectionSpacer(height: 12),
                            _buildBulletList(_schemeDetails!.documentsRequired),
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

  /// Summarize text to a maximum number of words
  String _summarizeText(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) {
      return text;
    }
    return '${words.take(maxWords).join(' ')}...';
  }

  /// Build a bullet point list
  Widget _buildBulletList(List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build a numbered list
  Widget _buildNumberedList(List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.value,
                        style: GoogleFonts.openSans(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
