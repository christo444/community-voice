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
        'created_at': now.toIso8601String(),
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

  // Update interview answers
  Future<Profile?> updateInterviewAnswers({
    required String phoneNumber,
    required Map<String, String?> answers,
  }) async {
    try {
      final updateData = {
        'occupation': answers['occupation'],
        'organised_unorganised_sector': answers['organisedUnorganisedSector'],
        'income_below': answers['incomeBelow'],
        'income_certificate': answers['incomeCertificate'],
        'agriculture_involved': answers['agricultureInvolved'],
        'land_ownership': answers['landOwnership'],
        'msme_status': answers['msmeStatus'],
        'education': answers['education'],
        'disability': answers['disability'],
        'special_category': answers['specialCategory'],
        'pension': answers['pension'],
        'aadhaar_linked_account': answers['aadhaarLinkedAccount'],
        'ration_card': answers['rationCard'],
        'caste_certificate': answers['casteCertificate'],
        'minority_community': answers['minorityCommunity'],
        'ews_certificate': answers['ewsCertificate'],
        'state_district': answers['stateDistrict'],
        'kutcha_house': answers['kutchaHouse'],
        'pregnant_or_lactating': answers['pregnantOrLactating'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('profile_details')
          .update(updateData)
          .eq('phone_number', phoneNumber)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error updating interview answers: $e');
      return null;
    }
  }
}
