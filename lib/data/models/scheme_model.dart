import '../../domain/entities/scheme.dart';
import 'criteria_model.dart';

/// Data model for scheme (matches scheme_data.json structure exactly)
class SchemeModel extends Scheme {
  const SchemeModel({
    required super.schemeId,
    required super.schemeName,
    required super.criteria,
    required super.active,
    super.description,
    super.benefits,
  });
  
  /// Create from JSON (scheme_data.json format)
  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      schemeId: json['scheme_id'] as String,
      schemeName: json['scheme_name'] as String,
      criteria: CriteriaModel.fromJson(json['criteria'] as Map<String, dynamic>),
      active: json['active'] as bool? ?? true,
      description: json['description'] as String?,
      benefits: json['benefits'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'scheme_id': schemeId,
      'scheme_name': schemeName,
      'criteria': (criteria as CriteriaModel).toJson(),
      'active': active,
      if (description != null) 'description': description,
      if (benefits != null) 'benefits': benefits,
    };
  }
  
  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    final criteriaModel = criteria as CriteriaModel;
    return {
      'scheme_id': schemeId,
      'scheme_name': schemeName,
      'active': active ? 1 : 0,
      'description': description,
      'benefits': benefits,
      ...criteriaModel.toDbMap(),
    };
  }
  
  /// Create from database map
  factory SchemeModel.fromDbMap(Map<String, dynamic> map) {
    return SchemeModel(
      schemeId: map['scheme_id'] as String,
      schemeName: map['scheme_name'] as String,
      criteria: CriteriaModel.fromDbMap(map),
      active: map['active'] == 1,
      description: map['description'] as String?,
      benefits: map['benefits'] as String?,
    );
  }
}
