import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../domain/repository/auth_repository.dart';
import 'pin_login_page.dart';

class ResetPinPage extends StatefulWidget {
  final String phoneNumber;

  const ResetPinPage({super.key, required this.phoneNumber});

  @override
  State<ResetPinPage> createState() => _ResetPinPageState();
}

class _ResetPinPageState extends State<ResetPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController =
      TextEditingController();
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
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty || pin.length != 4) {
      _showError('Please enter a 4-digit PIN');
      return;
    }

    if (pin != confirmPin) {
      _showError('PINs do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await _authRepository.updatePin(widget.phoneNumber, pin);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'PIN updated successfully. Please login again.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PinLoginPage(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        _showError('Failed to update PIN. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
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
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Same White AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 139, 58, 58)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              const Text(
                'Create New PIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 139, 58, 58),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Set new PIN for: ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 48),

              // ✅ New PIN Field
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                cursorColor:
                    const Color.fromARGB(255, 139, 58, 58),
                decoration: InputDecoration(
                  labelText: 'Enter new PIN',
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
              ),

              const SizedBox(height: 24),

              // ✅ Confirm PIN Field
              TextField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                cursorColor:
                    const Color.fromARGB(255, 139, 58, 58),
                decoration: InputDecoration(
                  labelText: 'Confirm new PIN',
                  labelStyle: const TextStyle(
                      color:
                          Color.fromARGB(255, 139, 58, 58)),
                  prefixIcon: const Icon(Icons.lock_outline,
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
                onSubmitted: (_) => _handleResetPin(),
              ),

              const SizedBox(height: 32),

              // ✅ Same Gradient Button
              Container(
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleResetPin,
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
                      : const Text(
                          'Update PIN',
                          style: TextStyle(
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