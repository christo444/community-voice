import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../domain/repository/profile_repository.dart';
import 'reset_pin_page.dart';

class ResetPinDobPage extends StatefulWidget {
  final String phoneNumber;

  const ResetPinDobPage({super.key, required this.phoneNumber});

  @override
  State<ResetPinDobPage> createState() => _ResetPinDobPageState();
}

class _ResetPinDobPageState extends State<ResetPinDobPage> {
  final TextEditingController _dobController = TextEditingController();
  final ProfileRepository _profileRepository = ProfileRepository();
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
    _dobController.dispose();
    super.dispose();
  }

  String _normalizeDob(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _handleVerifyDob() async {
    final inputDob = _dobController.text.trim();

    if (inputDob.isEmpty) {
      _showError('Please enter your date of birth');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile =
          await _profileRepository.getProfile(widget.phoneNumber);

      if (!mounted) return;

      final storedDob = profile?.dateOfBirth?.trim();
      if (storedDob == null || storedDob.isEmpty) {
        _showError('Date of birth not found.');
        return;
      }

      final normalizedInput = _normalizeDob(inputDob);
      final normalizedStored = _normalizeDob(storedDob);

      final isMatch = normalizedStored.length == 4
          ? normalizedInput.endsWith(normalizedStored)
          : normalizedInput == normalizedStored;

      if (!isMatch) {
        _showError('Date of birth does not match our records');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPinPage(phoneNumber: widget.phoneNumber),
        ),
      );
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

      // ✅ Same White AppBar Style
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
                'Verify Date of Birth',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 139, 58, 58),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter DOB for: ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 48),

              // ✅ Styled DOB Input (Same style as PIN field)
              TextField(
                controller: _dobController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9/\-]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                cursorColor:
                    const Color.fromARGB(255, 139, 58, 58),
                decoration: InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 139, 58, 58)),
                  prefixIcon: const Icon(Icons.calendar_today,
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
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Same Gradient Button Style
              Container(
                decoration: const BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius:
                      BorderRadius.all(Radius.circular(14)),
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleVerifyDob,
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
                          'Verify',
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