import '../../domain/entities/scheme.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/entities/criteria.dart';

/// Rule-based eligibility engine
/// This is deterministic and data-driven - NO AI/ML
class EligibilityEngine {
  /// Check if user is eligible for a specific scheme
  bool isEligible(UserSession user, Scheme scheme) {
    final criteria = scheme.criteria;
    
    // Check age criteria
    if (!_checkAge(user.age, criteria)) {
      return false;
    }
    
    // Check income criteria
    if (!_checkIncome(user.income, criteria)) {
      return false;
    }
    
    // Check category criteria
    if (!_checkCategory(user.category, criteria)) {
      return false;
    }
    
    // Check gender criteria
    if (!_checkGender(user.gender, criteria)) {
      return false;
    }
    
    // Check disability criteria
    if (!_checkDisability(user.isDisabled, criteria)) {
      return false;
    }
    
    // Check BPL criteria
    if (!_checkBpl(user.isBpl, criteria)) {
      return false;
    }
    
    return true;
  }
  
  /// Get all eligible schemes for a user
  List<Scheme> getEligibleSchemes(UserSession user, List<Scheme> allSchemes) {
    return allSchemes
        .where((scheme) => scheme.active && isEligible(user, scheme))
        .toList();
  }
  
  // Private helper methods for each criteria check
  
  bool _checkAge(int userAge, Criteria criteria) {
    if (criteria.minAge != null && userAge < criteria.minAge!) {
      return false;
    }
    if (criteria.maxAge != null && userAge > criteria.maxAge!) {
      return false;
    }
    return true;
  }
  
  bool _checkIncome(int userIncome, Criteria criteria) {
    if (criteria.incomeMax != null && userIncome > criteria.incomeMax!) {
      return false;
    }
    return true;
  }
  
  bool _checkCategory(dynamic userCategory, Criteria criteria) {
    if (criteria.categories == null || criteria.categories!.isEmpty) {
      return true; // No category restriction
    }
    return criteria.categories!.contains(userCategory);
  }
  
  bool _checkGender(dynamic userGender, Criteria criteria) {
    if (criteria.gender == null) {
      return true; // No gender restriction
    }
    return userGender == criteria.gender;
  }
  
  bool _checkDisability(bool userIsDisabled, Criteria criteria) {
    if (criteria.isDisabled == null) {
      return true; // No disability requirement
    }
    return userIsDisabled == criteria.isDisabled;
  }
  
  bool _checkBpl(bool userIsBpl, Criteria criteria) {
    if (criteria.isBpl == null) {
      return true; // No BPL requirement
    }
    return userIsBpl == criteria.isBpl;
  }
  
  /// Get eligibility reasons for debugging/display
  Map<String, bool> getEligibilityDetails(UserSession user, Scheme scheme) {
    final criteria = scheme.criteria;
    
    return {
      'age': _checkAge(user.age, criteria),
      'income': _checkIncome(user.income, criteria),
      'category': _checkCategory(user.category, criteria),
      'gender': _checkGender(user.gender, criteria),
      'disability': _checkDisability(user.isDisabled, criteria),
      'bpl': _checkBpl(user.isBpl, criteria),
    };
  }
}
