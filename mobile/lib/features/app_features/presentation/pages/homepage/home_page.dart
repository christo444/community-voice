// ignore_for_file: prefer_const_constructors

import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:community_voice/domain/repository/auth_repository.dart';
import 'package:community_voice/domain/repository/scheme_repository.dart';
import 'package:community_voice/domain/model/scheme.dart';
import 'package:community_voice/features/app_features/presentation/pages/auth/phone_input_page.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
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

  // Scheme repository for fetching data
  final SchemeRepository _schemeRepository = SchemeRepository();
  final AuthRepository _authRepository = AuthRepository();

  // State management
  bool _isLoading = true;
  List<Scheme> _matchedSchemes = [];
  String? _errorMessage;
  
  // Translation state
  final GoogleTranslator _translator = GoogleTranslator();
  Map<String, Map<String, String>> _translations = {}; // schemeId -> {name, description}
  bool _isTranslating = false;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadMatchedSchemes();
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

  // Handle language change - translate schemes if Malayalam is selected
  Future<void> _handleLanguageChange(String languageCode) async {
    if (languageCode == 'ml' && _matchedSchemes.isNotEmpty) {
      await _translateSchemes();
    } else {
      // Clear translations if switching back to English
      setState(() {
        _translations.clear();
      });
    }
  }
  
  // Translate all scheme names and descriptions to Malayalam
  Future<void> _translateSchemes() async {
    if (_isTranslating) return;
    
    setState(() {
      _isTranslating = true;
    });
    
    try {
      for (final scheme in _matchedSchemes) {
        // Skip if already translated
        if (_translations.containsKey(scheme.id)) continue;
        
        // Translate name and description
        final translatedName = await _translator.translate(
          scheme.schemeName,
          from: 'en',
          to: 'ml',
        );
        
        final translatedDesc = await _translator.translate(
          scheme.description ?? '',
          from: 'en',
          to: 'ml',
        );
        
        _translations[scheme.id] = {
          'name': translatedName.text,
          'description': translatedDesc.text,
        };
      }
      
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
  String _getDisplayName(Scheme scheme) {
    if (_currentLanguage == 'ml' && _translations.containsKey(scheme.id)) {
      return _translations[scheme.id]!['name']!;
    }
    return scheme.schemeName;
  }
  
  String _getDisplayDescription(Scheme scheme) {
    if (_currentLanguage == 'ml' && _translations.containsKey(scheme.id)) {
      return _translations[scheme.id]!['description']!;
    }
    return scheme.description ?? 'No description available';
  }

  // Load matched schemes for the current user
  Future<void> _loadMatchedSchemes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get user's phone number
      final phoneNumber = await _authRepository.getStoredPhoneNumber();

      if (phoneNumber == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      // Fetch matched schemes
      final schemes = await _schemeRepository.getMatchedSchemes(phoneNumber);

      print('✅ Loaded ${schemes.length} schemes from backend');

      setState(() {
        _matchedSchemes = schemes;
        _isLoading = false;
      });
      
      // Translate if Malayalam is selected
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      if (lang.languageCode == 'ml') {
        await _translateSchemes();
      }
    } catch (e) {
      print('❌ Error loading schemes: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load schemes: $e';
      });
    }
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
  void _showLogoutDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            lang.translate('logout'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
          content: Text(
            lang.translate('logoutConfirmMessage'),
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                lang.translate('cancel'),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
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
              child: Text(
                lang.translate('logout'),
                style: const TextStyle(
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
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      // ===== APP BAR WITH MAROON GRADIENT =====
      appBar: CustomAppBar(
        title: lang.translate('governmentSchemes'),
        logoPath: 'assets/images/logo.png',
        logoSize: 50.0,
        actions: [
          // Language button
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF800000),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 253, 240, 213)),
            tooltip: lang.translate('logout'),
            onPressed: () => _showLogoutDialog(lang),
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
                lang.translate('eligibleSchemes'),
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
          // List of Schemes with loading/error handling
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF800000),
                    ),
                  )
                : _errorMessage != null
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
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMatchedSchemes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF800000),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _matchedSchemes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  lang.translate('noSchemesFound'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Complete your profile to get personalized scheme recommendations',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMatchedSchemes,
                            color: const Color(0xFF800000),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              itemCount: _matchedSchemes.length,
                              itemBuilder: (context, index) {
                                final scheme = _matchedSchemes[index];
                                final displayName = _getDisplayName(scheme);
                                final displayDescription = _getDisplayDescription(scheme);
                                
                                return SchemeTile(
                                  name: displayName,
                                  description: displayDescription,
                                  matchPercentage: scheme.matchPercentage,
                                  onTap: () {
                                    // Navigate to detail page with scheme ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SchemeDetailPage(
                                          schemeId: scheme.id,
                                          name: displayName,
                                          description: displayDescription,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: VoiceButton(
                                    isSpeaking: speakingIndex == index,
                                    onPressed: () {
                                      // Toggle speech for this scheme
                                      _toggleSpeak(
                                        index,
                                        displayName,
                                        displayDescription,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}