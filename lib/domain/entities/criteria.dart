import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Domain entity representing scheme eligibility criteria
class Criteria extends Equatable {
  final int? minAge;
  final int? maxAge;
  final int? incomeMax;
  final List<Category>? categories;
  final Gender? gender;
  final bool? isDisabled;
  final bool? isBpl;
  
  const Criteria({
    this.minAge,
    this.maxAge,
    this.incomeMax,
    this.categories,
    this.gender,
    this.isDisabled,
    this.isBpl,
  });
  
  @override
  List<Object?> get props => [
    minAge,
    maxAge,
    incomeMax,
    categories,
    gender,
    isDisabled,
    isBpl,
  ];
}
