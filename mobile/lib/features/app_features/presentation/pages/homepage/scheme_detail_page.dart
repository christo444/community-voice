import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:community_voice/domain/repository/scheme_repository.dart';
import 'package:community_voice/domain/model/scheme.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:community_voice/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:community_voice/core/config/api_config.dart';

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
  // Track which section is currently speaking ('benefits', 'howToApply', 'documents', or null)
  String? speakingSection;

  // Repository and state
  final SchemeRepository _schemeRepository = SchemeRepository();
  SchemeDetails? _schemeDetails;
  bool _isLoading = true;
  String? _errorMessage;

  // Cached summarized text (1-2 sentences)
  String? _summarizedBenefits;

  // Translation state
  final GoogleTranslator _translator = GoogleTranslator();
  Map<String, String> _translations = {}; // field -> translated text
  bool _isTranslating = false;
  String _currentLanguage = 'en';

  // Request for help state
  bool _isSendingRequest = false;
  bool _requestSent = false;
  String? _requestError;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadSchemeDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context);
    if (lang.languageCode != _currentLanguage) {
      _currentLanguage = lang.languageCode;
      _handleLanguageChange(lang.languageCode);
    }
  }

  // Handle language change - translate content if Malayalam is selected
  Future<void> _handleLanguageChange(String languageCode) async {
    if (languageCode == 'ml' && _schemeDetails != null) {
      // Don't await - let translation happen in background
      _translateContent();
    } else {
      // Clear translations if switching back to English
      setState(() {
        _translations.clear();
      });
    }
  }

  // Translate all text content to Malayalam (optimized with parallel translations)
  Future<void> _translateContent() async {
    if (_isTranslating || _schemeDetails == null) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // Prepare all translation futures at once
      List<Future<void>> translationFutures = [];

      // Translate scheme name
      if (!_translations.containsKey('name')) {
        translationFutures.add(
          _translator
              .translate(widget.name, from: 'en', to: 'ml')
              .then((result) {
            _translations['name'] = result.text;
          }),
        );
      }

      // Translate benefits
      if (_summarizedBenefits != null &&
          !_translations.containsKey('benefits')) {
        translationFutures.add(
          _translator
              .translate(_summarizedBenefits!, from: 'en', to: 'ml')
              .then((result) {
            _translations['benefits'] = result.text;
          }),
        );
      }

      // Translate application process steps (parallel)
      for (int i = 0;
          i < _schemeDetails!.applicationProcess.length && i < 3;
          i++) {
        final key = 'app_process_$i';
        final text = _schemeDetails!.applicationProcess[i];
        if (!_translations.containsKey(key)) {
          translationFutures.add(
            _translator.translate(text, from: 'en', to: 'ml').then((result) {
              _translations[key] = result.text;
            }),
          );
        }
      }

      // Translate documents (parallel)
      for (int i = 0;
          i < _schemeDetails!.documentsRequired.length && i < 4;
          i++) {
        final key = 'document_$i';
        final text = _schemeDetails!.documentsRequired[i];
        if (!_translations.containsKey(key)) {
          translationFutures.add(
            _translator.translate(text, from: 'en', to: 'ml').then((result) {
              _translations[key] = result.text;
            }),
          );
        }
      }

      // Execute all translations in parallel
      await Future.wait(translationFutures);

      setState(() {
        _isTranslating = false;
      });
    } catch (e) {
      print('Translation error: $e');
      setState(() {
        _isTranslating = false;
      });
    }
  }

  // Get display text based on current language
  String _getDisplayText(String key, String defaultText) {
    if (_currentLanguage == 'ml' && _translations.containsKey(key)) {
      return _translations[key]!;
    }
    return defaultText;
  }

  // Load complete scheme details
  Future<void> _loadSchemeDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final details = await _schemeRepository.getSchemeDetails(widget.schemeId);

      if (details != null) {
        // Summarize benefits using Gemini (1-2 sentences)
        final benefitsFuture =
            details.benefits != null && details.benefits!.isNotEmpty
                ? _schemeRepository.summarizeText(details.benefits!)
                : Future.value('');

        final summarizedBenefits = await benefitsFuture;

        setState(() {
          _schemeDetails = details;
          _summarizedBenefits = summarizedBenefits;
          _isLoading = false;
        });

        // Trigger translation if Malayalam is selected (non-blocking)
        if (_currentLanguage == 'ml') {
          _translateContent();
        }
      } else {
        setState(() {
          _isLoading = false;
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
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Listen to completion to update state
    flutterTts.setCompletionHandler(() {
      setState(() {
        speakingSection = null;
      });
    });
  }

  // Function to toggle speech for a specific section
  Future<void> _toggleSectionSpeech(String section, String content) async {
    if (speakingSection == section) {
      // If this section is speaking, stop it
      await flutterTts.stop();
      setState(() {
        speakingSection = null;
      });
    } else {
      // Stop any other section and start this one
      await flutterTts.stop();

      // Set language based on current language
      await flutterTts
          .setLanguage(_currentLanguage == 'ml' ? 'ml-IN' : 'en-US');

      setState(() {
        speakingSection = section;
      });

      await flutterTts.speak(content);
    }
  }

  // Contact Paralegal logic
  Future<void> _contactParalegal() async {
    setState(() {
      _isSendingRequest = true;
      _requestError = null;
    });

    try {
      final authRepo = AuthRepository();
      final phoneNumber = await authRepo.getStoredPhoneNumber();

      if (phoneNumber == null) {
        throw Exception('User phone not found');
      }

      String name = 'User';
      String location = 'Unknown';

      try {
        final supabase = Supabase.instance.client;

        // Try getting profile details
        // Assuming table 'profile_details' or 'user_profiles' based on project conventions
        // We'll try querying 'users' table as fallback if profile fails, but users table might just have auth details
        final profileRes = await supabase
            .from('profile_details')
            .select()
            .eq('phone_number', phoneNumber)
            .maybeSingle();

        if (profileRes != null) {
          name = profileRes['name'] ?? profileRes['full_name'] ?? 'User';
          // Join parts if needed
          if (name == 'User' && profileRes['first_name'] != null) {
            name =
                '${profileRes['first_name']} ${profileRes['last_name'] ?? ''}'
                    .trim();
          }
          location = profileRes['place'] ??
              profileRes['address'] ??
              profileRes['district'] ??
              'Unknown Place';
        }
      } catch (e) {
        print('Profile fetch error: $e');
        // Proceed with defaults
        name = 'User $phoneNumber';
      }

      // Call Paralegal API
      final url = '${ApiConfig.paralegalApiBase}/user/request-help';
      print('Sending request to paralegal API: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'phone_number': phoneNumber,
              'location': location,
              'scheme_name': widget.name,
            }),
          )
          .timeout(const Duration(seconds: 10)); // Timeout after 10s

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _requestSent = true;
        });
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().length > 100
            ? '${e.toString().substring(0, 100)}...'
            : e.toString();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $errorMsg')));
      }
      setState(() {
        _requestError = e.toString();
        _requestSent = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingRequest = false;
        });
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
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: lang.translate('schemeDetails'),
        actions: [
          // Language toggle button
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF800000),
            ),
          ),
        ],
      ),
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
                              child: DetailTitle(
                                text: _getDisplayText('name', widget.name),
                              ),
                            ),
                          ),
                          const SectionSpacer(height: 20),

                          // Benefits Section (Summarized by Gemini - 1-2 sentences)
                          if (_summarizedBenefits != null &&
                              _summarizedBenefits!.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SectionHeading(
                                    text: _currentLanguage == 'ml'
                                        ? 'ആനുകൂല്യങ്ങൾ'
                                        : 'Benefits',
                                  ),
                                ),
                                VoiceButton(
                                  isSpeaking: speakingSection == 'benefits',
                                  onPressed: () {
                                    final benefitsText = _getDisplayText(
                                        'benefits', _summarizedBenefits!);
                                    final heading = _currentLanguage == 'ml'
                                        ? 'ആനുകൂല്യങ്ങൾ'
                                        : 'Benefits';
                                    _toggleSectionSpeech(
                                        'benefits', '$heading. $benefitsText');
                                  },
                                  size: 24,
                                ),
                              ],
                            ),
                            const SectionSpacer(height: 12),
                            _buildInfoCard(
                              _getDisplayText('benefits', _summarizedBenefits!),
                            ),
                            const SectionSpacer(height: 20),
                          ],

                          // Application Process Section (Top 3 steps)
                          if (_schemeDetails!
                              .applicationProcess.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SectionHeading(
                                    text: _currentLanguage == 'ml'
                                        ? 'എങ്ങനെ അപേക്ഷിക്കാം'
                                        : 'How to Apply',
                                  ),
                                ),
                                VoiceButton(
                                  isSpeaking: speakingSection == 'howToApply',
                                  onPressed: () {
                                    final steps = _getTranslatedList(
                                      _schemeDetails!.applicationProcess,
                                      'app_process',
                                      3,
                                    );
                                    final heading = _currentLanguage == 'ml'
                                        ? 'എങ്ങനെ അപേക്ഷിക്കാം'
                                        : 'How to Apply';
                                    final content =
                                        '$heading. ${steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('. ')}';
                                    _toggleSectionSpeech('howToApply', content);
                                  },
                                  size: 24,
                                ),
                              ],
                            ),
                            const SectionSpacer(height: 12),
                            _buildNumberedList(_getTranslatedList(
                              _schemeDetails!.applicationProcess,
                              'app_process',
                              3,
                            )),
                            const SectionSpacer(height: 20),
                          ],

                          // Documents Required Section (Top 4 items)
                          if (_schemeDetails!.documentsRequired.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SectionHeading(
                                    text: _currentLanguage == 'ml'
                                        ? 'ആവശ്യമായ രേഖകൾ'
                                        : 'Documents Needed',
                                  ),
                                ),
                                VoiceButton(
                                  isSpeaking: speakingSection == 'documents',
                                  onPressed: () {
                                    final docs = _getTranslatedList(
                                      _schemeDetails!.documentsRequired,
                                      'document',
                                      4,
                                    );
                                    final heading = _currentLanguage == 'ml'
                                        ? 'ആവശ്യമായ രേഖകൾ'
                                        : 'Documents Needed';
                                    final content =
                                        '$heading. ${docs.join('. ')}';
                                    _toggleSectionSpeech('documents', content);
                                  },
                                  size: 24,
                                ),
                              ],
                            ),
                            const SectionSpacer(height: 12),
                            _buildBulletList(_getTranslatedList(
                              _schemeDetails!.documentsRequired,
                              'document',
                              4,
                            )),
                            const SectionSpacer(height: 20),
                          ],

                          // Other sections can be added here as needed

                          // Contact Paralegal Button
                          const SectionSpacer(height: 20),
                          Center(
                            child: Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: (_isSendingRequest || _requestSent)
                                      ? null
                                      : _contactParalegal,
                                  icon: _isSendingRequest
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(2),
                                          child:
                                              const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                      : (_requestSent
                                          ? const Icon(Icons.check,
                                              color: Colors.white)
                                          : const Icon(Icons.support_agent,
                                              color: Colors.white)),
                                  label: Text(
                                    _requestSent
                                        ? lang.translate('requestSent')
                                        : lang.translate('contactParalegal'),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _requestSent
                                        ? Colors.green
                                        : const Color(0xFF800000),
                                    disabledBackgroundColor: _requestSent
                                        ? Colors.green.withOpacity(0.8)
                                        : Colors.grey,
                                    disabledForegroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    elevation: 4,
                                  ),
                                ),
                                if (_requestSent)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      '(${lang.translate('requestSent')})',
                                      style: GoogleFonts.openSans(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SectionSpacer(height: 32),
                        ],
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

  /// Limit list to a maximum number of items
  List<String> _limitList(List<String> items, int max) {
    return items.take(max).toList();
  }

  /// Get translated list items
  List<String> _getTranslatedList(
      List<String> items, String keyPrefix, int max) {
    final limitedItems = _limitList(items, max);
    if (_currentLanguage == 'ml') {
      return limitedItems.asMap().entries.map((entry) {
        final key = '${keyPrefix}_${entry.key}';
        return _getDisplayText(key, entry.value);
      }).toList();
    }
    return limitedItems;
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
