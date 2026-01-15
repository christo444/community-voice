import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_service.dart';

/// Production implementation using speech_to_text package
class SpeechToTextService implements VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  
  @override
  bool get isListening => _isListening;
  
  @override
  Future<bool> initialize() async {
    try {
      return await _speech.initialize(
        onError: (error) {
          // TODO: Implement proper error logging
          debugPrint('Speech recognition error: $error');
        },
        onStatus: (status) {
          // TODO: Implement proper status handling
          debugPrint('Speech recognition status: $status');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      return false;
    }
  }
  
  @override
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }
  
  @override
  Future<void> startListening(Function(String) onResult) async {
    if (!_speech.isAvailable) {
      await initialize();
    }
    
    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'en_IN', // Indian English - can be changed to hi_IN for Hindi
    );
  }
  
  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }
}
