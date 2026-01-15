import '../../core/constants/app_constants.dart';
import '../../domain/entities/criteria.dart';

/// Data model for scheme criteria (matches scheme_data.json structure)
class CriteriaModel extends Criteria {
  const CriteriaModel({
    super.minAge,
    super.maxAge,
    super.incomeMax,
    super.categories,
    super.gender,
    super.isDisabled,
    super.isBpl,
  });
  
  /// Create from JSON
  factory CriteriaModel.fromJson(Map<String, dynamic> json) {
    return CriteriaModel(
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      incomeMax: json['income_max'] as int?,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => _categoryFromString(e as String))
              .toList()
          : null,
      gender: json['gender'] != null
          ? _genderFromString(json['gender'] as String)
          : null,
      isDisabled: json['is_disabled'] as bool?,
      isBpl: json['is_bpl'] as bool?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (minAge != null) 'min_age': minAge,
      if (maxAge != null) 'max_age': maxAge,
      if (incomeMax != null) 'income_max': incomeMax,
      if (categories != null)
        'categories': categories!.map((e) => e.name.toUpperCase()).toList(),
      if (gender != null) 'gender': gender!.name.toUpperCase(),
      if (isDisabled != null) 'is_disabled': isDisabled,
      if (isBpl != null) 'is_bpl': isBpl,
    };
  }
  
  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'min_age': minAge,
      'max_age': maxAge,
      'income_max': incomeMax,
      'categories': categories != null
          ? categories!.map((e) => e.name).join(',')
          : null,
      'gender': gender?.name,
      'is_disabled': isDisabled == true ? 1 : 0,
      'is_bpl': isBpl == true ? 1 : 0,
    };
  }
  
  /// Create from database map
  factory CriteriaModel.fromDbMap(Map<String, dynamic> map) {
    return CriteriaModel(
      minAge: map['min_age'] as int?,
      maxAge: map['max_age'] as int?,
      incomeMax: map['income_max'] as int?,
      categories: map['categories'] != null
          ? (map['categories'] as String)
              .split(',')
              .map((e) => _categoryFromString(e))
              .toList()
          : null,
      gender: map['gender'] != null
          ? _genderFromString(map['gender'] as String)
          : null,
      isDisabled: map['is_disabled'] == 1,
      isBpl: map['is_bpl'] == 1,
    );
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
}
