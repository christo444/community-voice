import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/scheme_viewmodel.dart';
import 'voice_intake_screen.dart';

/// Home screen - entry point of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load schemes on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeViewModel>().loadSchemes();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Voice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<SchemeViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Welcome to Community Voice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Voice-driven welfare scheme access',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Scheme count card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${viewModel.schemes.length} Schemes Available',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (viewModel.lastSyncTime != null)
                          Text(
                            'Last synced: ${_formatDateTime(viewModel.lastSyncTime!)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Start Voice Intake button
                ElevatedButton.icon(
                  onPressed: viewModel.schemes.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoiceIntakeScreen(),
                            ),
                          );
                        },
                  icon: const Icon(Icons.mic, size: 32),
                  label: const Text('Start Voice Check'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sync button
                OutlinedButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => viewModel.syncSchemes(),
                  icon: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    viewModel.isLoading ? 'Syncing...' : 'Sync Schemes',
                  ),
                ),
                
                // Error message
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const Spacer(),
                
                // Info text
                const Text(
                  'Tap "Start Voice Check" to check your eligibility for welfare schemes using voice prompts',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Community Voice'),
        content: const Text(
          'Community Voice helps you check eligibility for welfare schemes using voice prompts.\n\n'
          'Features:\n'
          '• Voice-based data collection\n'
          '• Offline-first\n'
          '• Privacy-focused\n'
          '• No authentication required',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
