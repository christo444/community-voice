// lib/features/app_features/presentation/pages/auth/pin_setup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repository/auth_repository.dart';
import '../../../../../core/localization/language_provider.dart';
import '../../../../../core/widgets/language_toggle_button.dart';
import 'welcome_page.dart';

class PinSetupPage extends StatefulWidget {
  final String phoneNumber;
  
  const PinSetupPage({super.key, required this.phoneNumber});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSetupPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (pin.isEmpty || pin.length != 4) {
      _showError(lang.translate('enterPin'));
      return;
    }

    if (pin != confirmPin) {
      _showError(lang.translate('pinMismatch'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authRepository.registerUser(widget.phoneNumber, pin);

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        _showError(lang.translate('error'));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('${lang.translate('error')}: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF800000)),
          onPressed: () => Navigator.pop(context),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Title
              Text(
                lang.translate('pinSetup'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'For phone number: ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // PIN input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: lang.translate('enterPin'),
                  labelStyle: const TextStyle(color: Color(0xFF800000)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF800000)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              
              // Confirm PIN input
              TextField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: lang.translate('confirmPin'),
                  labelStyle: const TextStyle(color: Color(0xFF800000)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF800000)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                onSubmitted: (_) => _handleSetupPin(),
              ),
              
              const SizedBox(height: 32),
              
              // Create PIN button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSetupPin,
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
                        lang.translate('setupPin'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}