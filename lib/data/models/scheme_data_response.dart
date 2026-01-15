/// Response model matching scheme_data.json structure exactly
class SchemeDataResponse {
  final MetadataModel metadata;
  final List<Map<String, dynamic>> schemes;
  
  SchemeDataResponse({
    required this.metadata,
    required this.schemes,
  });
  
  /// Create from JSON
  factory SchemeDataResponse.fromJson(Map<String, dynamic> json) {
    return SchemeDataResponse(
      metadata: MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>),
      schemes: (json['schemes'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// Metadata model from scheme_data.json
class MetadataModel {
  final String version;
  final String lastUpdated;
  
  MetadataModel({
    required this.version,
    required this.lastUpdated,
  });
  
  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      version: json['version'] as String,
      lastUpdated: json['last_updated'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'last_updated': lastUpdated,
    };
  }
}
