/// Aadhaar OCR service interface - STUB ONLY for MVP
/// NO actual Aadhaar validation or image storage
abstract class AadhaarOcrService {
  /// Extract basic info from Aadhaar (stubbed)
  /// Returns: {age, gender}
  Future<Map<String, dynamic>?> extractInfo();
}

/// Stub implementation - returns dummy data
class StubAadhaarOcrService implements AadhaarOcrService {
  @override
  Future<Map<String, dynamic>?> extractInfo() async {
    // Simulate OCR processing delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return stub data
    // TODO: In production, integrate actual OCR SDK (not UIDAI validation)
    return {
      'age': 65,
      'gender': 'male',
    };
  }
}
