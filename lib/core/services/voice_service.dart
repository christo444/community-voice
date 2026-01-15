/// Voice service interface - abstraction for speech recognition
/// This allows for easy stubbing/mocking when API keys are not available
abstract class VoiceService {
  /// Initialize the voice service
  Future<bool> initialize();
  
  /// Start listening for voice input
  Future<void> startListening(Function(String) onResult);
  
  /// Stop listening
  Future<void> stopListening();
  
  /// Check if voice recognition is available
  Future<bool> isAvailable();
  
  /// Check if currently listening
  bool get isListening;
}
