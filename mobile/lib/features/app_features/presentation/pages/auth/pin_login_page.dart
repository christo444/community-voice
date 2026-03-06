// lib/features/app_features/presentation/pages/auth/pin_login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repository/auth_repository.dart';
import '../../../../../core/localization/language_provider.dart';
import '../../../../../core/widgets/language_toggle_button.dart';
import 'welcome_page.dart';
import 'reset_pin_dob_page.dart';

class PinLoginPage extends StatefulWidget {
  final String phoneNumber;

  const PinLoginPage({super.key, required this.phoneNumber});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final TextEditingController _pinController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 139, 58, 58),
      Color.fromARGB(255, 74, 14, 26),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final pin = _pinController.text.trim();
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (pin.isEmpty || pin.length != 4) {
      _showError(lang.translate('enterYourPin'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid =
          await _authRepository.loginUser(widget.phoneNumber, pin);

      if (!mounted) return;

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WelcomePage(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        _showError(lang.translate('invalidPin'));
        _pinController.clear();
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

      // ✅ GRADIENT APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: LanguageToggleButton(
              backgroundColor: Colors.white,
              foregroundColor:
                  Color.fromARGB(255, 139, 58, 58),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 139, 58, 58),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter PIN for: ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 48),

              // ✅ PIN Input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                cursorColor:
                    const Color.fromARGB(255, 139, 58, 58),
                decoration: InputDecoration(
                  labelText: lang.translate('enterYourPin'),
                  labelStyle: const TextStyle(
                      color:
                          Color.fromARGB(255, 139, 58, 58)),
                  prefixIcon: const Icon(Icons.lock,
                      color:
                          Color.fromARGB(255, 139, 58, 58)),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 139, 58, 58),
                        width: 2),
                  ),
                  counterText: '',
                ),
                onSubmitted: (_) => _handleLogin(),
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ResetPinDobPage(
                                phoneNumber:
                                    widget.phoneNumber),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot PIN?',
                    style: TextStyle(
                        color: Color.fromARGB(
                            255, 139, 58, 58)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Gradient Login Button
              Container(
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
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
                                    Color>(Colors.white),
                          ),
                        )
                      : Text(
                          lang.translate('loginWithPin'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
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