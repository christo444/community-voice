// ignore_for_file: prefer_const_constructors

import 'package:community_voice/features/app_features/presentation/widgets/widgets.dart';
import 'package:community_voice/domain/repository/auth_repository.dart';
import 'package:community_voice/domain/repository/profile_repository.dart';
import 'package:community_voice/features/app_features/presentation/pages/auth/phone_input_page.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
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

  // Show profile dialog with Aadhaar details
  void _showProfileDialog() async {
    final authRepository = AuthRepository();
    final profileRepository = ProfileRepository();
    final phoneNumber = await authRepository.getStoredPhoneNumber();
    
    print('Debug: Phone number from storage: $phoneNumber'); // Debug log
    
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final profile = await profileRepository.getProfile(phoneNumber);
      print('Debug: Profile retrieved: $profile'); // Debug log
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text(
              'Profile Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF800000),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile != null) ...[
                    _buildProfileField('Name', profile.name),
                    _buildProfileField('Phone', profile.phoneNumber),
                    _buildProfileField('Date of Birth', profile.dateOfBirth),
                    _buildProfileField('Age', profile.age?.toString()),
                    _buildProfileField('Gender', profile.gender),
                    _buildProfileField('Address', profile.address),
                  ] else ...[
                    Text(
                      'No profile data found for phone: $phoneNumber\n\nPlease complete your Aadhaar verification process first.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Close',
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
    } catch (e) {
      print('Debug: Error retrieving profile: $e'); // Debug log
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrieving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to build profile field widgets
  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not provided',
            style: TextStyle(
              fontSize: 16,
              color: value != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
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
          // Profile button
          IconButton(
            icon: const Icon(Icons.person, color: Color.fromARGB(255, 253, 240, 213)),
            tooltip: 'Profile',
            onPressed: _showProfileDialog,
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