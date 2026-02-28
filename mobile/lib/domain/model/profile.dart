class Profile {
  final String phoneNumber;
  final String? name;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Interview question fields
  final String? occupation;
  final String? organisedUnorganisedSector;
  final String? incomeBelow;
  final String? incomeCertificate;
  final String? agricultureInvolved;
  final String? landOwnership;
  final String? msmeStatus;
  final String? education;
  final String? disability;
  final String? specialCategory;
  final String? pension;
  final String? aadhaarLinkedAccount;
  final String? rationCard;
  final String? casteCertificate;
  final String? minorityCommunity;
  final String? ewsCertificate;
  final String? stateDistrict;
  final String? kutchaHouse;
  final String? pregnantOrLactating;

  Profile({
    required this.phoneNumber,
    this.name,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.occupation,
    this.organisedUnorganisedSector,
    this.incomeBelow,
    this.incomeCertificate,
    this.agricultureInvolved,
    this.landOwnership,
    this.msmeStatus,
    this.education,
    this.disability,
    this.specialCategory,
    this.pension,
    this.aadhaarLinkedAccount,
    this.rationCard,
    this.casteCertificate,
    this.minorityCommunity,
    this.ewsCertificate,
    this.stateDistrict,
    this.kutchaHouse,
    this.pregnantOrLactating,
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
      occupation: json['occupation'] as String?,
      organisedUnorganisedSector: json['organised_unorganised_sector'] as String?,
      incomeBelow: json['income_below'] as String?,
      incomeCertificate: json['income_certificate'] as String?,
      agricultureInvolved: json['agriculture_involved'] as String?,
      landOwnership: json['land_ownership'] as String?,
      msmeStatus: json['msme_status'] as String?,
      education: json['education'] as String?,
      disability: json['disability'] as String?,
      specialCategory: json['special_category'] as String?,
      pension: json['pension'] as String?,
      aadhaarLinkedAccount: json['aadhaar_linked_account'] as String?,
      rationCard: json['ration_card'] as String?,
      casteCertificate: json['caste_certificate'] as String?,
      minorityCommunity: json['minority_community'] as String?,
      ewsCertificate: json['ews_certificate'] as String?,
      stateDistrict: json['state_district'] as String?,
      kutchaHouse: json['kutcha_house'] as String?,
      pregnantOrLactating: json['pregnant_or_lactating'] as String?,
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
      'occupation': occupation,
      'organised_unorganised_sector': organisedUnorganisedSector,
      'income_below': incomeBelow,
      'income_certificate': incomeCertificate,
      'agriculture_involved': agricultureInvolved,
      'land_ownership': landOwnership,
      'msme_status': msmeStatus,
      'education': education,
      'disability': disability,
      'special_category': specialCategory,
      'pension': pension,
      'aadhaar_linked_account': aadhaarLinkedAccount,
      'ration_card': rationCard,
      'caste_certificate': casteCertificate,
      'minority_community': minorityCommunity,
      'ews_certificate': ewsCertificate,
      'state_district': stateDistrict,
      'kutcha_house': kutchaHouse,
      'pregnant_or_lactating': pregnantOrLactating,
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
    String? occupation,
    String? organisedUnorganisedSector,
    String? incomeBelow,
    String? incomeCertificate,
    String? agricultureInvolved,
    String? landOwnership,
    String? msmeStatus,
    String? education,
    String? disability,
    String? specialCategory,
    String? pension,
    String? aadhaarLinkedAccount,
    String? rationCard,
    String? casteCertificate,
    String? minorityCommunity,
    String? ewsCertificate,
    String? stateDistrict,
    String? kutchaHouse,
    String? pregnantOrLactating,
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
      occupation: occupation ?? this.occupation,
      organisedUnorganisedSector: organisedUnorganisedSector ?? this.organisedUnorganisedSector,
      incomeBelow: incomeBelow ?? this.incomeBelow,
      incomeCertificate: incomeCertificate ?? this.incomeCertificate,
      agricultureInvolved: agricultureInvolved ?? this.agricultureInvolved,
      landOwnership: landOwnership ?? this.landOwnership,
      msmeStatus: msmeStatus ?? this.msmeStatus,
      education: education ?? this.education,
      disability: disability ?? this.disability,
      specialCategory: specialCategory ?? this.specialCategory,
      pension: pension ?? this.pension,
      aadhaarLinkedAccount: aadhaarLinkedAccount ?? this.aadhaarLinkedAccount,
      rationCard: rationCard ?? this.rationCard,
      casteCertificate: casteCertificate ?? this.casteCertificate,
      minorityCommunity: minorityCommunity ?? this.minorityCommunity,
      ewsCertificate: ewsCertificate ?? this.ewsCertificate,
      stateDistrict: stateDistrict ?? this.stateDistrict,
      kutchaHouse: kutchaHouse ?? this.kutchaHouse,
      pregnantOrLactating: pregnantOrLactating ?? this.pregnantOrLactating,
    );
  }
}