import 'dart:async';
import 'voice_service.dart';

/// Stub implementation for testing when speech API is not available
/// Returns simulated responses for development/testing
class StubVoiceService implements VoiceService {
  bool _isListening = false;
  Timer? _simulationTimer;
  
  @override
  bool get isListening => _isListening;
  
  @override
  Future<bool> initialize() async {
    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
  
  @override
  Future<bool> isAvailable() async {
    return true;
  }
  
  @override
  Future<void> startListening(Function(String) onResult) async {
    _isListening = true;
    
    // Simulate voice recognition after 2 seconds
    _simulationTimer = Timer(const Duration(seconds: 2), () {
      // Return a simulated response
      // In real usage, this would be actual voice input
      onResult('Yes'); // Default stub response
      _isListening = false;
    });
  }
  
  @override
  Future<void> stopListening() async {
    _isListening = false;
    _simulationTimer?.cancel();
  }
}

/// Helper to create appropriate voice service based on environment
class VoiceServiceFactory {
  /// Create voice service
  /// Set useStub = true for development without API keys
  static VoiceService create({bool useStub = false}) {
    if (useStub) {
      return StubVoiceService();
    }
    // TODO: Uncomment when ready to use real speech recognition
    // return SpeechToTextService();
    return StubVoiceService(); // Default to stub for MVP
  }
}
