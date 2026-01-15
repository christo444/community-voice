import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart' hide Category;
import '../../core/constants/app_constants.dart' as constants show Category;
import '../../data/models/user_session_model.dart';
import '../../domain/usecases/user_session_usecases.dart';

/// ViewModel for voice intake flow
class VoiceIntakeViewModel extends ChangeNotifier {
  final SaveUserSession _saveUserSession;
  
  // User data collected through voice
  int? _age;
  Gender? _gender;
  int? _income;
  constants.Category? _category;
  bool? _isDisabled;
  bool? _isBpl;
  
  bool _isProcessing = false;
  String? _currentPrompt;
  int _currentStep = 0;
  
  VoiceIntakeViewModel({
    required SaveUserSession saveUserSession,
  }) : _saveUserSession = saveUserSession;
  
  // Getters
  int? get age => _age;
  Gender? get gender => _gender;
  int? get income => _income;
  constants.Category? get category => _category;
  bool? get isDisabled => _isDisabled;
  bool? get isBpl => _isBpl;
  bool get isProcessing => _isProcessing;
  String? get currentPrompt => _currentPrompt;
  int get currentStep => _currentStep;
  
  // Voice prompts for each step
  final List<String> _prompts = [
    'What is your age? Say the number.',
    'What is your gender? Say Male, Female, or Other.',
    'What is your monthly income? Say Below 10,000, 10,000 to 20,000, 20,000 to 50,000, or Above 50,000.',
    'What is your category? Say General, SC, ST, OBC, or EWS.',
    'Do you have any disability? Say Yes or No.',
    'Do you have a BPL card? Say Yes or No.',
  ];
  
  /// Start the voice intake flow
  void startIntake() {
    _currentStep = 0;
    _currentPrompt = _prompts[0];
    _resetData();
    notifyListeners();
  }
  
  /// Process voice input for current step
  Future<bool> processVoiceInput(String input) async {
    _isProcessing = true;
    notifyListeners();
    
    bool success = false;
    
    try {
      switch (_currentStep) {
        case 0: // Age
          _age = _parseAge(input);
          success = _age != null;
          break;
        case 1: // Gender
          _gender = _parseGender(input);
          success = _gender != null;
          break;
        case 2: // Income
          _income = _parseIncome(input);
          success = _income != null;
          break;
        case 3: // Category
          _category = _parseCategory(input);
          success = _category != null;
          break;
        case 4: // Disability
          _isDisabled = _parseYesNo(input);
          success = _isDisabled != null;
          break;
        case 5: // BPL
          _isBpl = _parseYesNo(input);
          success = _isBpl != null;
          break;
      }
      
      if (success) {
        _currentStep++;
        if (_currentStep < _prompts.length) {
          _currentPrompt = _prompts[_currentStep];
        } else {
          _currentPrompt = 'Processing your information...';
        }
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
    
    return success;
  }
  
  /// Check if intake is complete
  bool isComplete() {
    return _currentStep >= _prompts.length;
  }
  
  /// Save the collected session
  Future<void> saveSession() async {
    if (!isComplete()) {
      throw Exception('Voice intake not complete');
    }
    
    final session = UserSessionModel(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      age: _age!,
      gender: _gender!,
      income: _income!,
      category: _category!,
      isDisabled: _isDisabled!,
      isBpl: _isBpl!,
      createdAt: DateTime.now(),
    );
    
    await _saveUserSession(session);
  }
  
  void _resetData() {
    _age = null;
    _gender = null;
    _income = null;
    _category = null;
    _isDisabled = null;
    _isBpl = null;
  }
  
  // Parsing helpers
  
  int? _parseAge(String input) {
    final age = int.tryParse(input.trim());
    if (age != null && age >= 0 && age <= 120) {
      return age;
    }
    return null;
  }
  
  Gender? _parseGender(String input) {
    final normalized = input.toLowerCase().trim();
    if (normalized.contains('male') && !normalized.contains('female')) {
      return Gender.male;
    } else if (normalized.contains('female')) {
      return Gender.female;
    } else if (normalized.contains('other')) {
      return Gender.other;
    }
    return null;
  }
  
  int? _parseIncome(String input) {
    final normalized = input.toLowerCase().trim();
    if (normalized.contains('below') || normalized.contains('10000') || normalized.contains('10,000')) {
      return 5000; // Representative value for below 10k
    } else if (normalized.contains('10') && (normalized.contains('20') || normalized.contains('twenty'))) {
      return 15000;
    } else if (normalized.contains('20') && (normalized.contains('50') || normalized.contains('fifty'))) {
      return 35000;
    } else if (normalized.contains('above') || normalized.contains('50000') || normalized.contains('50,000')) {
      return 60000;
    }
    return null;
  }
  
  constants.Category? _parseCategory(String input) {
    final normalized = input.toLowerCase().trim();
    if (normalized.contains('sc')) {
      return constants.Category.sc;
    } else if (normalized.contains('st')) {
      return constants.Category.st;
    } else if (normalized.contains('obc')) {
      return constants.Category.obc;
    } else if (normalized.contains('ews')) {
      return constants.Category.ews;
    } else if (normalized.contains('general')) {
      return constants.Category.general;
    }
    return null;
  }
  
  bool? _parseYesNo(String input) {
    final normalized = input.toLowerCase().trim();
    if (normalized.contains('yes') || normalized.contains('haan')) {
      return true;
    } else if (normalized.contains('no') || normalized.contains('nahi')) {
      return false;
    }
    return null;
  }
}
