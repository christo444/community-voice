import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/profile.dart';

class ProfileDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  // Get profile by phone number
  Future<Profile?> getProfile(String phoneNumber) async {
    try {
      final response = await _client
          .from('profile_details')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Create or update profile with OCR data
  Future<Profile?> upsertProfile({
    required String phoneNumber,
    required String? name,
    required String? dateOfBirth,
    required int? age,
    required String? gender,
    required String? address,
  }) async {
    try {
      final now = DateTime.now();
      final profileData = {
        'phone_number': phoneNumber,
        'name': name,
        'date_of_birth': dateOfBirth,
        'age': age,
        'gender': gender,
        'address': address,
        'updated_at': now.toIso8601String(),
      };

      final response = await _client
          .from('profile_details')
          .upsert(profileData)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error upserting profile: $e');
      return null;
    }
  }

  // Delete profile
  Future<bool> deleteProfile(String phoneNumber) async {
    try {
      await _client
          .from('profile_details')
          .delete()
          .eq('phone_number', phoneNumber);
      return true;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }
}