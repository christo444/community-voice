import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/stub_voice_service.dart';
import '../viewmodels/voice_intake_viewmodel.dart';
import 'eligibility_result_screen.dart';

/// Voice intake screen - collects user data through voice prompts
class VoiceIntakeScreen extends StatefulWidget {
  const VoiceIntakeScreen({super.key});
  
  @override
  State<VoiceIntakeScreen> createState() => _VoiceIntakeScreenState();
}

class _VoiceIntakeScreenState extends State<VoiceIntakeScreen> {
  late VoiceService _voiceService;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVoice();
    context.read<VoiceIntakeViewModel>().startIntake();
  }
  
  Future<void> _initializeVoice() async {
    _voiceService = VoiceServiceFactory.create(useStub: true); // Using stub for MVP
    final success = await _voiceService.initialize();
    setState(() {
      _isInitialized = success;
    });
  }
  
  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Intake'),
      ),
      body: Consumer<VoiceIntakeViewModel>(
        builder: (context, viewModel, child) {
          if (!_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (viewModel.isComplete()) {
            // Auto-navigate to results
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _processResults(context, viewModel);
            });
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: viewModel.currentStep / 6,
                ),
                const SizedBox(height: 24),
                
                // Step indicator
                Text(
                  'Step ${viewModel.currentStep + 1} of 6',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Current prompt
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mic,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.currentPrompt ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Voice input button
                ElevatedButton.icon(
                  onPressed: viewModel.isProcessing
                      ? null
                      : () => _startListening(context, viewModel),
                  icon: _voiceService.isListening
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.mic),
                  label: Text(
                    _voiceService.isListening
                        ? 'Listening...'
                        : 'Tap to Speak',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Manual input fallback (for testing/accessibility)
                OutlinedButton.icon(
                  onPressed: viewModel.isProcessing
                      ? null
                      : () => _showManualInput(context, viewModel),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Type Instead'),
                ),
                
                const SizedBox(height: 24),
                
                // Collected data summary
                if (viewModel.age != null) _buildDataSummary(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDataSummary(VoiceIntakeViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Information Collected:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (viewModel.age != null) Text('Age: ${viewModel.age}'),
            if (viewModel.gender != null) Text('Gender: ${viewModel.gender!.name}'),
            if (viewModel.income != null) Text('Income: ₹${viewModel.income}'),
            if (viewModel.category != null) Text('Category: ${viewModel.category!.name.toUpperCase()}'),
            if (viewModel.isDisabled != null) Text('Disability: ${viewModel.isDisabled! ? "Yes" : "No"}'),
            if (viewModel.isBpl != null) Text('BPL Card: ${viewModel.isBpl! ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
  
  Future<void> _startListening(
    BuildContext context,
    VoiceIntakeViewModel viewModel,
  ) async {
    await _voiceService.startListening((result) async {
      await _voiceService.stopListening();
      
      final success = await viewModel.processVoiceInput(result);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not understand "$result". Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
  
  void _showManualInput(
    BuildContext context,
    VoiceIntakeViewModel viewModel,
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Input'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: viewModel.currentPrompt,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.processVoiceInput(controller.text);
              
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid input. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _processResults(
    BuildContext context,
    VoiceIntakeViewModel viewModel,
  ) async {
    // Save session
    await viewModel.saveSession();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EligibilityResultScreen(
            age: viewModel.age!,
            gender: viewModel.gender!,
            income: viewModel.income!,
            category: viewModel.category!,
            isDisabled: viewModel.isDisabled!,
            isBpl: viewModel.isBpl!,
          ),
        ),
      );
    }
  }
}
