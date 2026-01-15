/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Community Voice';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'community_voice.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String schemesTable = 'schemes';
  static const String userSessionsTable = 'user_sessions';
  
  // API Endpoints (mock for now - TODO: Replace with actual backend)
  static const String baseUrl = 'https://api.example.com';
  static const String schemesEndpoint = '/api/schemes';
  
  // Voice Prompt Timeout
  static const Duration voiceTimeout = Duration(seconds: 5);
  
  // Sync
  static const String schemeDataVersion = '1.0';
}

/// Categories for welfare schemes
enum Category {
  general,
  sc,
  st,
  obc,
  ews,
}

/// Gender options
enum Gender {
  male,
  female,
  other,
}

/// Income brackets (structured voice options)
enum IncomeBracket {
  below10k,     // Below 10,000
  range10to20k, // 10,000 to 20,000
  range20to50k, // 20,000 to 50,000
  above50k,     // Above 50,000
}

/// Yes/No response
enum YesNo {
  yes,
  no,
}

/// Employment status
enum EmploymentStatus {
  employed,
  unemployed,
  selfEmployed,
  retired,
}

/// Extension methods for enums
extension IncomeBracketExtension on IncomeBracket {
  int get maxIncome {
    switch (this) {
      case IncomeBracket.below10k:
        return 10000;
      case IncomeBracket.range10to20k:
        return 20000;
      case IncomeBracket.range20to50k:
        return 50000;
      case IncomeBracket.above50k:
        return 999999999;
    }
  }
  
  String get displayText {
    switch (this) {
      case IncomeBracket.below10k:
        return 'Below ₹10,000';
      case IncomeBracket.range10to20k:
        return '₹10,000 to ₹20,000';
      case IncomeBracket.range20to50k:
        return '₹20,000 to ₹50,000';
      case IncomeBracket.above50k:
        return 'Above ₹50,000';
    }
  }
}

extension CategoryExtension on Category {
  String get displayText {
    switch (this) {
      case Category.general:
        return 'General';
      case Category.sc:
        return 'SC';
      case Category.st:
        return 'ST';
      case Category.obc:
        return 'OBC';
      case Category.ews:
        return 'EWS';
    }
  }
}

extension GenderExtension on Gender {
  String get displayText {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}
