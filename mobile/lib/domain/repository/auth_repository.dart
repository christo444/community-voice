// lib/domain/repository/auth_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_datasource.dart';
import '../model/user.dart';

class AuthRepository {
  final AuthDatasource _authDatasource = AuthDatasource();
  
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPhoneNumber = 'phone_number';

  // Check if user is already logged in (from local storage)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get stored phone number
  Future<String?> getStoredPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  // Save login state locally
  Future<void> _saveLoginState(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyPhoneNumber, phoneNumber);
  }

  // Clear login state
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhoneNumber);
  }

  // Check if user exists
  Future<User?> checkUserExists(String phoneNumber) async {
    return await _authDatasource.getUserByPhone(phoneNumber);
  }

  // Register new user
  Future<User?> registerUser(String phoneNumber, String pin) async {
    final user = await _authDatasource.createUser(phoneNumber, pin);
    if (user != null) {
      await _saveLoginState(phoneNumber);
    }
    return user;
  }

  // Login existing user
  Future<bool> loginUser(String phoneNumber, String pin) async {
    final isValid = await _authDatasource.verifyPin(phoneNumber, pin);
    if (isValid) {
      await _saveLoginState(phoneNumber);
    }
    return isValid;
  }

  // Auto-login for returning users
  Future<User?> autoLogin() async {
    final isLogged = await isLoggedIn();
    if (!isLogged) return null;

    final phoneNumber = await getStoredPhoneNumber();
    if (phoneNumber == null) return null;

    return await _authDatasource.getUserByPhone(phoneNumber);
  }

  // Reset PIN for existing user
  Future<bool> updatePin(String phoneNumber, String newPin) async {
    return await _authDatasource.updatePin(phoneNumber, newPin);
  }
}