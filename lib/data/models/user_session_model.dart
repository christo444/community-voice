import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_session.dart';

/// Data model for user session
class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.sessionId,
    required super.age,
    required super.gender,
    required super.income,
    required super.category,
    required super.isDisabled,
    required super.isBpl,
    required super.createdAt,
  });
  
  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'session_id': sessionId,
      'age': age,
      'gender': gender.name,
      'income': income,
      'category': category.name,
      'is_disabled': isDisabled ? 1 : 0,
      'is_bpl': isBpl ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Create from database map
  factory UserSessionModel.fromDbMap(Map<String, dynamic> map) {
    return UserSessionModel(
      sessionId: map['session_id'] as String,
      age: map['age'] as int,
      gender: _genderFromString(map['gender'] as String),
      income: map['income'] as int,
      category: _categoryFromString(map['category'] as String),
      isDisabled: map['is_disabled'] == 1,
      isBpl: map['is_bpl'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  
  static Gender _genderFromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
  
  static Category _categoryFromString(String value) {
    switch (value.toLowerCase()) {
      case 'sc':
        return Category.sc;
      case 'st':
        return Category.st;
      case 'obc':
        return Category.obc;
      case 'ews':
        return Category.ews;
      default:
        return Category.general;
    }
  }
}
