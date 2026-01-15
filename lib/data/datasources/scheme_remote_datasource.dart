import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/scheme_data_response.dart';
import '../models/scheme_model.dart';

/// Remote data source for fetching schemes from backend
class SchemeRemoteDataSource {
  final http.Client client;
  
  SchemeRemoteDataSource(this.client);
  
  /// Fetch schemes from backend API
  /// TODO: Replace with actual backend URL when available
  Future<List<SchemeModel>> fetchSchemes() async {
    try {
      final response = await client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.schemesEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final schemeData = SchemeDataResponse.fromJson(jsonData);
        
        return schemeData.schemes
            .map((schemeJson) => SchemeModel.fromJson(schemeJson))
            .toList();
      } else {
        throw Exception('Failed to fetch schemes: ${response.statusCode}');
      }
    } catch (e) {
      // For MVP: Return mock data if API is not available
      return _getMockSchemes();
    }
  }
  
  /// Mock schemes for development/testing
  /// This matches the scheme_data.json structure exactly
  List<SchemeModel> _getMockSchemes() {
    final mockJson = {
      "metadata": {
        "version": "1.0",
        "last_updated": "2026-01-15"
      },
      "schemes": [
        {
          "scheme_id": "OLD_AGE_PENSION",
          "scheme_name": "Old Age Pension",
          "description": "Monthly pension for senior citizens",
          "benefits": "₹1,000 per month",
          "criteria": {
            "min_age": 60,
            "income_max": 10000,
            "categories": ["SC", "ST", "OBC", "GENERAL"]
          },
          "active": true
        },
        {
          "scheme_id": "WIDOW_PENSION",
          "scheme_name": "Widow Pension",
          "description": "Financial support for widows",
          "benefits": "₹500 per month",
          "criteria": {
            "min_age": 18,
            "gender": "FEMALE",
            "income_max": 15000
          },
          "active": true
        },
        {
          "scheme_id": "DISABILITY_ALLOWANCE",
          "scheme_name": "Disability Allowance",
          "description": "Support for persons with disabilities",
          "benefits": "₹1,500 per month",
          "criteria": {
            "is_disabled": true,
            "income_max": 20000
          },
          "active": true
        },
        {
          "scheme_id": "BPL_RATION_CARD",
          "scheme_name": "BPL Ration Card",
          "description": "Subsidized food grains",
          "benefits": "Subsidized food grains at ration shops",
          "criteria": {
            "income_max": 10000,
            "is_bpl": true
          },
          "active": true
        },
        {
          "scheme_id": "SC_ST_SCHOLARSHIP",
          "scheme_name": "SC/ST Scholarship",
          "description": "Educational support for SC/ST students",
          "benefits": "Tuition fee support",
          "criteria": {
            "min_age": 5,
            "max_age": 25,
            "categories": ["SC", "ST"]
          },
          "active": true
        }
      ]
    };
    
    final schemeData = SchemeDataResponse.fromJson(mockJson);
    return schemeData.schemes
        .map((schemeJson) => SchemeModel.fromJson(schemeJson))
        .toList();
  }
}
