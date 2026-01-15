import 'package:flutter/foundation.dart';
import '../../core/services/eligibility_engine.dart';
import '../../domain/entities/scheme.dart';
import '../../domain/entities/user_session.dart';

/// ViewModel for eligibility results
class EligibilityViewModel extends ChangeNotifier {
  final EligibilityEngine _eligibilityEngine;
  
  List<Scheme> _eligibleSchemes = [];
  bool _isProcessing = false;
  
  EligibilityViewModel({
    required EligibilityEngine eligibilityEngine,
  }) : _eligibilityEngine = eligibilityEngine;
  
  List<Scheme> get eligibleSchemes => _eligibleSchemes;
  bool get isProcessing => _isProcessing;
  
  /// Calculate eligible schemes for user
  Future<void> calculateEligibility(
    UserSession userSession,
    List<Scheme> allSchemes,
  ) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Run eligibility check
      _eligibleSchemes = _eligibilityEngine.getEligibleSchemes(
        userSession,
        allSchemes,
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Get detailed eligibility for a specific scheme
  Map<String, bool> getEligibilityDetails(
    UserSession userSession,
    Scheme scheme,
  ) {
    return _eligibilityEngine.getEligibilityDetails(userSession, scheme);
  }
}
