import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';

class InterviewQuestionsPage extends StatefulWidget {
  const InterviewQuestionsPage({super.key});

  @override
  State<InterviewQuestionsPage> createState() => _InterviewQuestionsPageState();
}

class _InterviewQuestionsPageState extends State<InterviewQuestionsPage> {
  final List<TextEditingController> _controllers =
      List.generate(20, (_) => TextEditingController());

  final List<String> questions = [
    "നിങ്ങളുടെ ഇപ്പോഴത്തെ തൊഴിൽ എന്താണ്?",
    "നിങ്ങളുടെ ജോലി സംഘടിത മേഖലയിലാണോ അസംഘടിത മേഖലയിലാണോ?",
    "നിങ്ങളുടെ വാർഷിക കുടുംബ വരുമാനം സർക്കാരിന്റെ താഴ്ന്ന വരുമാന പരിധിക്ക് താഴെയാണോ?",
    "നിങ്ങളുടെ കൈവശം സാധുവായ വരുമാന സർട്ടിഫിക്കറ്റ് ഉണ്ടോ?",
    "നിങ്ങൾ കൃഷിയിലോ അനുബന്ധ പ്രവർത്തനങ്ങളിലോ ഏർപ്പെട്ടിട്ടുണ്ടോ?",
    "നിങ്ങൾക്ക് കൃഷിഭൂമി സ്വന്തമാണോ അതോ പാട്ടത്തിനാണോ?",
    "നിങ്ങൾ ഒരു ചെറുകിട ബിസിനസ്സോ എംഎസ്എംഇയോ നടത്തുന്നുണ്ടോ അല്ലെങ്കിൽ ആരംഭിക്കാൻ പദ്ധതിയിടുന്നുണ്ടോ?",
    "നിങ്ങളുടെ ഏറ്റവും ഉയർന്ന വിദ്യാഭ്യാസ നിലവാരം എന്താണ്?",
    "നിങ്ങൾ നിലവിൽ പഠിക്കുകയാണോ അതോ നൈപുണ്യ പരിശീലനം തേടുകയാണോ?",
    "നിങ്ങൾക്ക് സർക്കാർ നൽകിയ വൈകല്യ സർട്ടിഫിക്കറ്റ് ഉണ്ടോ?",
    "നിങ്ങൾ ഒരു വിധവയോ, ഒറ്റയ്ക്ക് ജീവിക്കുന്ന രക്ഷിതാവോ, അല്ലെങ്കിൽ ആശ്രിത കുടുംബാംഗമോ ആണോ?",
    "നിങ്ങൾക്ക് നിലവിൽ സർക്കാരിൽ നിന്ന് എന്തെങ്കിലും പെൻഷൻ ലഭിക്കുന്നുണ്ടോ?",
    "ആധാറുമായി ലിങ്ക് ചെയ്ത ബാങ്ക് അക്കൗണ്ട് നിങ്ങൾക്കുണ്ടോ?",
    "നിങ്ങൾക്ക് റേഷൻ കാർഡുണ്ടോ?",
    "നിങ്ങളുടെ കൈവശം ജാതി അല്ലെങ്കിൽ സമുദായ സർട്ടിഫിക്കറ്റ് ഉണ്ടോ?",
  ];

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
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitAnswers() {
    for (int i = 0; i < _controllers.length; i++) {
      debugPrint("Answer ${i + 1}: ${_controllers[i].text}");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===== MATCHED APPBAR STYLE =====
      appBar: AppBar(
        title: const Text(
          "Interview Questions",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
      ),

      /// ===== BODY =====
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questions[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              /// MATCHED INPUT FIELD STYLE
              TextField(
                controller: _controllers[index],
                maxLines: 3,
                cursorColor: maroon,
                decoration: InputDecoration(
                  hintText: "Enter your answer",
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

              const SizedBox(height: 22),
            ],
          );
        },
      ),

      /// ===== MATCHED GRADIENT BUTTON =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: maroonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton(
            onPressed: _submitAnswers,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(
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
