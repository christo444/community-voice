// lib/features/app_features/presentation/pages/auth/phone_input_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../domain/repository/auth_repository.dart';
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

  final LinearGradient _maroonGradient = const LinearGradient(
    colors: [
      Color(0xFF8B3A3A),
      Color(0xFF4A0E1A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
          backgroundColor: Color.fromARGB(255, 255, 17, 0),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingUser =
          await _authRepository.checkUserExists(phoneNumber);

      if (!mounted) return;

      if (existingUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinLoginPage(phoneNumber: phoneNumber),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinSetupPage(phoneNumber: phoneNumber),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ===== GRADIENT LOGO =====
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: _maroonGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your phone number to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 82, 82, 82),
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
                  labelText: 'Phone Number',
                  labelStyle:
                      const TextStyle(color: Color(0xFF800000)),
                  prefixIcon: const Icon(Icons.phone,
                      color: Color(0xFF800000)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF800000),
                      width: 2,
                    ),
                  ),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 24),

              // ===== GRADIENT CONTINUE BUTTON =====
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isLoading ? null : _handleContinue,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: _maroonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
