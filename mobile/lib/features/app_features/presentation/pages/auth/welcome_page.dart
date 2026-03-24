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
      final profile =
          await profileRepository.getProfile(widget.phoneNumber);

      if (!mounted) return;

      if (profile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AadhaarTestLauncher(),
          ),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLogoutDialog(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            lang.translate('logout'),
            style: const TextStyle(
              color: Color.fromARGB(255, 139, 58, 58),
              fontWeight: FontWeight.bold,
            ),
          ),
          content:
              const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                lang.translate('cancel'),
                style:
                    const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Color.fromARGB(
                      255, 139, 58, 58),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Gradient Maroon AppBar with Back + Title
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Community Voice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(
                    255, 139, 58, 58),
                Color.fromARGB(
                    255, 74, 14, 26),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        actions: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor:
                  Color.fromARGB(
                      255, 139, 58, 58),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout,
                color: Colors.white),
            onPressed: () =>
                _showLogoutDialog(context, lang),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                            255, 139, 58, 58)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Color.fromARGB(
                        255, 139, 58, 58),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                lang.translate('welcome'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(
                      255, 139, 58, 58),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              Container(
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                          255, 139, 58, 58)
                      .withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromARGB(
                            255, 139, 58, 58)
                        .withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'You will remain logged in until you manually logout.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                decoration:
                    const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(
                          Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () =>
                          _handleContinue(
                              context),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent,
                    shadowColor:
                        Colors.transparent,
                    padding:
                        const EdgeInsets
                            .symmetric(
                            vertical: 16),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<
                                        Color>(
                                    Colors
                                        .white),
                          ),
                        )
                      : Text(
                          lang.translate(
                              'continue'),
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}