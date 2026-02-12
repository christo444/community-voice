class Profile {
  final String phoneNumber;
  final String? name;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.phoneNumber,
    this.name,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'name': name,
      'date_of_birth': dateOfBirth,
      'age': age,
      'gender': gender,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? phoneNumber,
    String? name,
    String? dateOfBirth,
    int? age,
    String? gender,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}