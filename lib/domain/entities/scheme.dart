import 'package:equatable/equatable.dart';
import 'criteria.dart';

/// Domain entity representing a welfare scheme
class Scheme extends Equatable {
  final String schemeId;
  final String schemeName;
  final Criteria criteria;
  final bool active;
  final String? description;
  final String? benefits;
  
  const Scheme({
    required this.schemeId,
    required this.schemeName,
    required this.criteria,
    required this.active,
    this.description,
    this.benefits,
  });
  
  @override
  List<Object?> get props => [
    schemeId,
    schemeName,
    criteria,
    active,
    description,
    benefits,
  ];
}
