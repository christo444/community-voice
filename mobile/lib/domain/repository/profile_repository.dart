import '../../data/datasources/profile_datasource.dart';
import '../model/profile.dart';

class ProfileRepository {
  final ProfileDatasource _profileDatasource = ProfileDatasource();

  // Get user profile
  Future<Profile?> getProfile(String phoneNumber) async {
    return await _profileDatasource.getProfile(phoneNumber);
  }

  // Save OCR extracted data
  Future<Profile?> saveOcrData({
    required String phoneNumber,
    required String? name,
    required String? dateOfBirth,
    required int? age,
    required String? gender,
    required String? address,
  }) async {
    return await _profileDatasource.upsertProfile(
      phoneNumber: phoneNumber,
      name: name,
      dateOfBirth: dateOfBirth,
      age: age,
      gender: gender,
      address: address,
    );
  }

  // Save interview answers
  Future<Profile?> saveInterviewAnswers({
    required String phoneNumber,
    required Map<String, String?> answers,
  }) async {
    return await _profileDatasource.updateInterviewAnswers(
      phoneNumber: phoneNumber,
      answers: answers,
    );
  }

  // Delete profile
  Future<bool> deleteProfile(String phoneNumber) async {
    return await _profileDatasource.deleteProfile(phoneNumber);
  }
}