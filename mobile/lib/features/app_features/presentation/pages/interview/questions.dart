import 'package:flutter/material.dart';
import 'package:community_voice/features/app_features/presentation/pages/homepage/home_page.dart';


class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final List<String> questions = [
    "നിങ്ങളുടെ ഇപ്പോഴത്തെ തൊഴിൽ എന്താണ്?",
    "നിങ്ങളുടെ വാർഷിക കുടുംബ വരുമാനം 2.5 ലക്ഷത്തിൽ താഴെയാണോ?",
    "നിങ്ങൾ കൃഷിയിലോ അനുബന്ധ പ്രവർത്തനങ്ങളിലോ ഏർപ്പെട്ടിട്ടുണ്ടോ?",
    "നിങ്ങൾക്ക് കൃഷിഭൂമി സ്വന്തമാണോ അതോ പാട്ടത്തിനാണോ?",
    "നിങ്ങൾ ഒരു ചെറിയ ബിസിനസ്സ് നടത്തുന്നുണ്ടോ അതോ ആരംഭിക്കാൻ പദ്ധതിയിടുന്നുണ്ടോ?",
    "നിങ്ങളുടെ ഏറ്റവും ഉയർന്ന വിദ്യാഭ്യാസ നിലവാരം എന്താണ്?",
    "നിങ്ങളുടെ കൈവശം വൈകല്യ സർട്ടിഫിക്കറ്റ് ഉണ്ടോ?",
    "നിങ്ങൾ ഒരു മുതിർന്ന പൗര പെൻഷൻ ഉടമയാണോ?",
    "നിങ്ങൾ ഒരു വിധവയാണോ അതോ ഒറ്റയ്ക്ക് ജീവിക്കുന്ന ഒരാളാണോ?",
    "ആധാറുമായി ലിങ്ക് ചെയ്ത ബാങ്ക് അക്കൗണ്ട് നിങ്ങൾക്കുണ്ടോ?",
  ];

  late final List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers =
        List.generate(questions.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitAnswers() async {
    for (int i = 0; i < questions.length; i++) {
      debugPrint("${questions[i]} ${controllers[i].text}");
    }

    // Optional: show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Answers submitted")),
    );

    // Navigate to HomePage (replace current page)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== APP BAR (AADHAAR GRADIENT) =====
      appBar: AppBar(
        title: const Text(
          "Questions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8B3A3A),
                Color(0xFF4A0E1A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      backgroundColor: const Color.fromARGB(255, 237, 233, 233),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questions[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A0E1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controllers[index],
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Type your answer here",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B3A3A),
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // ===== SUBMIT BUTTON (AADHAAR GRADIENT) =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B3A3A),
                  Color(0xFF4A0E1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitAnswers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
