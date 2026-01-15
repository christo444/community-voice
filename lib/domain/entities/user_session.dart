import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Domain entity representing user session data
class UserSession extends Equatable {
  final String sessionId;
  final int age;
  final Gender gender;
  final int income;
  final Category category;
  final bool isDisabled;
  final bool isBpl;
  final DateTime createdAt;
  
  const UserSession({
    required this.sessionId,
    required this.age,
    required this.gender,
    required this.income,
    required this.category,
    required this.isDisabled,
    required this.isBpl,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [
    sessionId,
    age,
    gender,
    income,
    category,
    isDisabled,
    isBpl,
    createdAt,
  ];
}
