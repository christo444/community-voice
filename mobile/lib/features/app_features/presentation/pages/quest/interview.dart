import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';
import 'package:community_voice/core/localization/language_provider.dart';
import 'package:community_voice/core/widgets/language_toggle_button.dart';
import 'package:community_voice/domain/repository/profile_repository.dart';
import 'package:community_voice/domain/repository/auth_repository.dart';

class InterviewQuestionsPage extends StatefulWidget {
  const InterviewQuestionsPage({super.key});

  @override
  State<InterviewQuestionsPage> createState() => _InterviewQuestionsPageState();
}

class _InterviewQuestionsPageState extends State<InterviewQuestionsPage> {
  final List<TextEditingController> _controllers = List.generate(14, (_) => TextEditingController());
  final List<String> _questionKeys = [
    'q1', 'q2', 'q3', 'q4', 'q5', 'q6', 'q7', 
    'q8', 'q9', 'q10', 'q11', 'q12', 'q13', 'q14'
  ];
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int? _currentListeningIndex;
  final translator = GoogleTranslator();
  bool _isSaving = false;

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color maroon = Color.fromARGB(255, 139, 58, 58);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _startListening(int index) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    bool available = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _currentListeningIndex = index;
      });

      // Use Malayalam locale if Malayalam is selected
      String localeId = lang.languageCode == 'ml' ? 'ml_IN' : 'en_US';

      _speech.listen(
        onResult: (result) {
          setState(() {
            _controllers[index].text = result.recognizedWords;
          });
        },
        localeId: localeId,
      );
    } else {
      print('Speech recognition not available');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _currentListeningIndex = null;
    });
  }

  Future<String> _translateToEnglish(String text) async {
    try {
      if (text.isEmpty) return '';
      
      // Check if text contains Malayalam characters
      final malayalamRegex = RegExp(r'[\u0D00-\u0D7F]');
      if (!malayalamRegex.hasMatch(text)) {
        // Text is already in English or other non-Malayalam language
        return text;
      }

      // Translate from Malayalam to English
      var translation = await translator.translate(text, from: 'ml', to: 'en');
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      // Return original text if translation fails
      return text;
    }
  }

  Future<void> _submitAnswers() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get phone number from auth
      final authRepository = AuthRepository();
      final phoneNumber = await authRepository.getStoredPhoneNumber();

      if (phoneNumber == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Translate all answers to English before storing
      final translatedAnswers = <String, String?>{};
      final fieldNames = [
        'occupation',
        'organisedUnorganisedSector',
        'incomeBelow',
        'incomeCertificate',
        'agricultureInvolved',
        'landOwnership',
        'msmeStatus',
        'education',
        'disability',
        'specialCategory',
        'pension',
        'aadhaarLinkedAccount',
        'rationCard',
        'casteCertificate',
      ];

      for (int i = 0; i < _controllers.length; i++) {
        String answer = _controllers[i].text.trim();
        if (answer.isNotEmpty) {
          translatedAnswers[fieldNames[i]] = await _translateToEnglish(answer);
        } else {
          translatedAnswers[fieldNames[i]] = null;
        }
      }

      // Save to database
      final profileRepository = ProfileRepository();
      final result = await profileRepository.saveInterviewAnswers(
        phoneNumber: phoneNumber,
        answers: translatedAnswers,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answers saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save answers. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting answers: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          lang.translate('interviewQuestions'),
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questionKeys.length,
        itemBuilder: (context, index) {
          final isCurrentlyListening = _isListening && _currentListeningIndex == index;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.translate(_questionKeys[index]),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllers[index],
                      maxLines: 3,
                      cursorColor: maroon,
                      decoration: InputDecoration(
                        hintText: lang.translate('enterAnswer'),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: maroon, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: isCurrentlyListening ? null : maroonGradient,
                      color: isCurrentlyListening ? Colors.red : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isCurrentlyListening) {
                          _stopListening();
                        } else {
                          _startListening(index);
                        }
                      },
                      icon: Icon(
                        isCurrentlyListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                      tooltip: isCurrentlyListening 
                          ? lang.translate('stopListening')
                          : lang.translate('speakAnswer'),
                    ),
                  ),
                ],
              ),
              if (isCurrentlyListening)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    lang.translate('listening'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 22),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: maroonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitAnswers,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    lang.translate('submit'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
