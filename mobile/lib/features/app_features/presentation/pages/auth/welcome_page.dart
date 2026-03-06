// lib/features/app_features/presentation/pages/auth/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repository/auth_repository.dart';
import '../../../../../core/localization/language_provider.dart';
import '../../../../../core/widgets/language_toggle_button.dart';
import '../../../../../domain/repository/profile_repository.dart';
import '../homepage/home_page.dart';
import 'phone_input_page.dart';
import '../ocr_screens/aadhaar_test_launcher.dart';

class WelcomePage extends StatefulWidget {
  final String phoneNumber;

  const WelcomePage({super.key, required this.phoneNumber});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = false;

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

  Future<void> _handleContinue(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final profileRepository = ProfileRepository();
      final profile = await profileRepository.getProfile(widget.phoneNumber);

      if (!mounted) return;

      if (profile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AadhaarTestLauncher()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ Gradient AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
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
              foregroundColor: Color.fromARGB(255, 139, 58, 58),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ✅ Gradient Icon Box
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: maroonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  lang.translate('welcome'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 139, 58, 58),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  widget.phoneNumber,
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
                    color: const Color.fromARGB(255, 139, 58, 58).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 139, 58, 58).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color.fromARGB(255, 139, 58, 58),
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.translate('welcome'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 139, 58, 58),
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

                // ✅ Gradient Continue Button
                Container(
                  decoration: const BoxDecoration(
                    gradient: maroonGradient,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleContinue(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            lang.translate('continue'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
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
                style: const TextStyle(color: Color.fromARGB(255, 139, 58, 58)),
              ),
            ),
          ],
        );
      },
    );
  }
}