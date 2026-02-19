// lib/features/app_features/presentation/pages/auth/phone_input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repository/auth_repository.dart';
import '../../../../../core/localization/language_provider.dart';
import '../../../../../core/widgets/language_toggle_button.dart';
import 'pin_setup_page.dart';
import 'pin_login_page.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('pleaseEnterValidPhoneNumber')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user exists
      final existingUser = await _authRepository.checkUserExists(phoneNumber);

      if (!mounted) return;

      if (existingUser != null) {
        // User exists - go to PIN login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PinLoginPage(phoneNumber: phoneNumber),
          ),
        );
      } else {
        // New user - go to PIN setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PinSetupPage(phoneNumber: phoneNumber),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.translate('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo/Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF800000), // Maroon
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                lang.translate('welcome'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                lang.translate('enterPhone'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Phone input field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: lang.translate('phoneNumber'),
                  labelStyle: const TextStyle(color: Color(0xFF800000)),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF800000)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF800000)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF800000), width: 2),
                  ),
                  counterText: '',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                        ),
                      ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}