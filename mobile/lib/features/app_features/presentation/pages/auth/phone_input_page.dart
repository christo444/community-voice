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
      final existingUser =
          await _authRepository.checkUserExists(phoneNumber);

      if (!mounted) return;

      if (existingUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinLoginPage(phoneNumber: phoneNumber),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinSetupPage(phoneNumber: phoneNumber),
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

      // ✅ GRADIENT APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: maroonGradient),
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ✅ Gradient Logo Box
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(Radius.circular(24)),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 55,
                  color: Colors.white,
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

              // ✅ Styled Phone Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                cursorColor:
                    const Color.fromARGB(255, 139, 58, 58),
                decoration: InputDecoration(
                  labelText: lang.translate('phoneNumber'),
                  labelStyle: const TextStyle(
                      color:
                          Color.fromARGB(255, 139, 58, 58)),
                  prefixIcon: const Icon(Icons.phone,
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
              ),

              const SizedBox(height: 28),

              // ✅ Gradient Continue Button
              Container(
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleContinue,
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
                          lang.translate('continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
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