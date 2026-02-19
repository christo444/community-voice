// lib/data/datasources/auth_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/model/user.dart' as model;

class AuthDatasource {
  final SupabaseClient _client = SupabaseConfig.client;

  // Check if user exists by phone number
  Future<model.User?> getUserByPhone(String phoneNumber) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      if (response == null) return null;
      return model.User.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Create new user with phone number and PIN
  Future<model.User?> createUser(String phoneNumber, String pin) async {
    try {
      final now = DateTime.now();
      final userData = {
        'phone_number': phoneNumber,
        'pin': pin,
        'created_at': now.toIso8601String(),
        'last_login_at': now.toIso8601String(),
      };

      final response = await _client
          .from('users')
          .insert(userData)
          .select()
          .single();

      return model.User.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Verify PIN for existing user
  Future<bool> verifyPin(String phoneNumber, String pin) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('pin', pin)
          .maybeSingle();

      if (response != null) {
        // Update last login time
        await _client
            .from('users')
            .update({'last_login_at': DateTime.now().toIso8601String()})
            .eq('phone_number', phoneNumber);
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin(String phoneNumber) async {
    try {
      await _client
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('phone_number', phoneNumber);
    } catch (e) {
      print('Error updating last login: $e');
    }
  }
}