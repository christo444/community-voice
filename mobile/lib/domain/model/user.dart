// lib/domain/model/user.dart

class User {
  final String phoneNumber;
  final String pin;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.phoneNumber,
    required this.pin,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['phone_number'] as String,
      pin: json['pin'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'pin': pin,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? phoneNumber,
    String? pin,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pin: pin ?? this.pin,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}