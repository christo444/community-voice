// lib/features/app_features/presentation/pages/auth/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repository/auth_repository.dart';
import '../../../../../core/localization/language_provider.dart';
import '../../../../../core/widgets/language_toggle_button.dart';
import 'phone_input_page.dart';
import '../ocr_screens/aadhaar_test_launcher.dart';

class WelcomePage extends StatelessWidget {
  final String phoneNumber;
  
  const WelcomePage({super.key, required this.phoneNumber});

  Future<void> _handleLogout(BuildContext context) async {
    final authRepository = AuthRepository();
    await authRepository.logout();
    
    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PhoneInputPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        title: const Text(
          'Community Voice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF800000),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context, lang),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Welcome icon
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Color(0xFF800000),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              
              // Welcome title
              Text(
                lang.translate('welcome'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Phone number display
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF800000).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF800000).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF800000),
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang.translate('welcome'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF800000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You will remain logged in until you manually logout',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Continue button - Continue to Aadhaar verification
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AadhaarTestLauncher(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  lang.translate('continue'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    ));
  }

  void _showLogoutDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.translate('logout')),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                lang.translate('cancel'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
              child: Text(
                lang.translate('logout'),
                style: const TextStyle(color: Color(0xFF800000)),
              ),
            ),
          ],
        );
      },
    );
  }
}