/// Scheme Model - represents a government scheme
class Scheme {
  final String id;
  final String schemeName;
  final String? description;
  final String? benefits;
  final int? matchPercentage;
  final List<String>? matchedCriteria;
  final List<String>? unmatchedCriteria;
  final String? reasoning;

  Scheme({
    required this.id,
    required this.schemeName,
    this.description,
    this.benefits,
    this.matchPercentage,
    this.matchedCriteria,
    this.unmatchedCriteria,
    this.reasoning,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['scheme_id'] ?? json['id'] ?? '',
      schemeName: json['scheme_name'] ?? json['schemeName'] ?? '',
      description: json['description'],
      benefits: json['benefits'],
      matchPercentage:
          (json['match_percentage'] ?? json['matchPercentage'])?.toInt(),
      matchedCriteria:
          (json['matched_criteria'] ?? json['matchedCriteria']) != null
              ? List<String>.from(
                  json['matched_criteria'] ?? json['matchedCriteria'])
              : null,
      unmatchedCriteria:
          (json['unmatched_criteria'] ?? json['unmatchedCriteria']) != null
              ? List<String>.from(
                  json['unmatched_criteria'] ?? json['unmatchedCriteria'])
              : null,
      reasoning: json['reasoning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheme_name': schemeName,
      'description': description,
      'benefits': benefits,
      'match_percentage': matchPercentage,
      'matched_criteria': matchedCriteria,
      'unmatched_criteria': unmatchedCriteria,
      'reasoning': reasoning,
    };
  }
}

/// Scheme Details Model - complete scheme information
class SchemeDetails {
  final String id;
  final String schemeName;
  final String? description;
  final String? benefits;
  final List<String> eligibility;
  final List<String> exclusions;
  final List<String> applicationProcess;
  final List<String> documentsRequired;
  final List<String> faqs;
  final String? pdfFileName;
  final String? sourceUrl;
  final String? rawText;
  final DateTime? uploadedAt;
  final DateTime? createdAt;

  SchemeDetails({
    required this.id,
    required this.schemeName,
    this.description,
    this.benefits,
    this.eligibility = const [],
    this.exclusions = const [],
    this.applicationProcess = const [],
    this.documentsRequired = const [],
    this.faqs = const [],
    this.pdfFileName,
    this.sourceUrl,
    this.rawText,
    this.uploadedAt,
    this.createdAt,
  });

  factory SchemeDetails.fromJson(Map<String, dynamic> json) {
    return SchemeDetails(
      id: json['id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      description: json['description'],
      benefits: json['benefits'],
      eligibility: json['eligibility'] != null
          ? List<String>.from(json['eligibility'])
          : [],
      exclusions: json['exclusions'] != null
          ? List<String>.from(json['exclusions'])
          : [],
      applicationProcess: json['application_process'] != null
          ? List<String>.from(json['application_process'])
          : [],
      documentsRequired: json['documents_required'] != null
          ? List<String>.from(json['documents_required'])
          : [],
      faqs: json['faqs'] != null ? List<String>.from(json['faqs']) : [],
      pdfFileName: json['pdf_file_name'],
      sourceUrl: json['source_url'],
      rawText: json['raw_text'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheme_name': schemeName,
      'description': description,
      'benefits': benefits,
      'eligibility': eligibility,
      'exclusions': exclusions,
      'application_process': applicationProcess,
      'documents_required': documentsRequired,
      'faqs': faqs,
      'pdf_file_name': pdfFileName,
      'source_url': sourceUrl,
      'raw_text': rawText,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
