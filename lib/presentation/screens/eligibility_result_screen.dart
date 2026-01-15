import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_session_model.dart';
import '../viewmodels/scheme_viewmodel.dart';
import '../viewmodels/eligibility_viewmodel.dart';

/// Eligibility result screen - shows eligible schemes
class EligibilityResultScreen extends StatefulWidget {
  final int age;
  final Gender gender;
  final int income;
  final Category category;
  final bool isDisabled;
  final bool isBpl;
  
  const EligibilityResultScreen({
    super.key,
    required this.age,
    required this.gender,
    required this.income,
    required this.category,
    required this.isDisabled,
    required this.isBpl,
  });
  
  @override
  State<EligibilityResultScreen> createState() => _EligibilityResultScreenState();
}

class _EligibilityResultScreenState extends State<EligibilityResultScreen> {
  @override
  void initState() {
    super.initState();
    _calculateEligibility();
  }
  
  Future<void> _calculateEligibility() async {
    final session = UserSessionModel(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      age: widget.age,
      gender: widget.gender,
      income: widget.income,
      category: widget.category,
      isDisabled: widget.isDisabled,
      isBpl: widget.isBpl,
      createdAt: DateTime.now(),
    );
    
    final schemes = context.read<SchemeViewModel>().schemes;
    await context.read<EligibilityViewModel>().calculateEligibility(
      session,
      schemes,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Eligible Schemes'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: Consumer<EligibilityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isProcessing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User info summary
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Age', '${widget.age} years'),
                          _buildInfoRow('Gender', widget.gender.displayText),
                          _buildInfoRow('Income', '₹${widget.income}/month'),
                          _buildInfoRow('Category', widget.category.displayText),
                          _buildInfoRow('Disability', widget.isDisabled ? 'Yes' : 'No'),
                          _buildInfoRow('BPL Card', widget.isBpl ? 'Yes' : 'No'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Results header
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${viewModel.eligibleSchemes.length} Schemes Found',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Eligible schemes list
                  if (viewModel.eligibleSchemes.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No schemes found matching your criteria',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Check back later as new schemes may be added',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...viewModel.eligibleSchemes.map((scheme) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.account_balance,
                          color: Colors.green,
                        ),
                        title: Text(
                          scheme.schemeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: scheme.description != null
                            ? Text(scheme.description!)
                            : null,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (scheme.benefits != null) ...[
                                  const Text(
                                    'Benefits:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(scheme.benefits!),
                                  const SizedBox(height: 12),
                                ],
                                const Text(
                                  'Scheme ID:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(scheme.schemeId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Back to Home'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Note: This is an eligibility check only. Please visit the respective offices for application procedures.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
