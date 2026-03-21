import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../../domain/model/scheme.dart';

class SchemeDatasource {
  static const String _defaultHost = 'localhost:5000';
  static const String _androidEmulatorHost = '10.0.2.2:5000';
  static const String _apiPath = '/api/schemes';

  // Optional override: flutter run --dart-define=SCHEME_API_BASE_URL=http://192.168.1.10:5000/api/schemes
  static const String _overrideBaseUrl =
      String.fromEnvironment('SCHEME_API_BASE_URL', defaultValue: '');

  String get baseUrl {
    if (_overrideBaseUrl.trim().isNotEmpty) {
      return _overrideBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    }

    if (Platform.isAndroid) {
      return 'http://$_androidEmulatorHost$_apiPath';
    }

    return 'http://$_defaultHost$_apiPath';
  }

  /// Fetch matched schemes for a user based on their phone number
  /// Returns schemes where user meets eligibility criteria
  Future<List<Scheme>> getMatchedSchemes(String phoneNumber) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📞 FETCHING SCHEMES');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Phone: $phoneNumber');
      print('URL: $baseUrl/match/$phoneNumber');

      final url = Uri.parse('$baseUrl/match/$phoneNumber');
      print('Parsed URI: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📡 RESPONSE RECEIVED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Status Code: ${response.statusCode}');
      print(
          'Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final dynamic data = jsonData['data'];
          final List<dynamic> matchedSchemes;

          if (data is Map<String, dynamic> && data['matched_schemes'] is List) {
            matchedSchemes = data['matched_schemes'] as List<dynamic>;
          } else if (data is List) {
            matchedSchemes = data;
          } else if (jsonData['matched_schemes'] is List) {
            matchedSchemes = jsonData['matched_schemes'] as List<dynamic>;
          } else {
            throw Exception('Invalid response format: missing matched_schemes');
          }

          final schemes = matchedSchemes
              .map((schemeJson) => Scheme.fromJson(schemeJson))
              .toList();

          print('✅  Successfully parsed ${schemes.length} schemes');
          return schemes;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load schemes: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ NETWORK ERROR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Cannot connect to backend');
      print('Make sure:');
      print('1. Backend server is running (python app.py)');
      print('2. App can reach backend host: $baseUrl');
      print(
          '3. If using a real device, pass --dart-define=SCHEME_API_BASE_URL=http://<your-ip>:5000/api/schemes');
      print('Error: $e');
      throw Exception('Network error: Cannot connect to server');
    } on TimeoutException {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('⏱️ TIMEOUT');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Request took longer than 10 seconds');
      print('💡 Backend might not be accessible from emulator');
      throw Exception('Request timeout');
    } on FormatException catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ JSON PARSE ERROR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Invalid JSON response from server');
      print('Error: $e');
      throw Exception('Invalid response format');
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ UNEXPECTED ERROR');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error type: ${e.runtimeType}');
      print('Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch complete details for a specific scheme
  Future<SchemeDetails?> getSchemeDetails(String schemeId) async {
    try {
      print('📄 Fetching details for scheme: $schemeId');

      final url = Uri.parse('$baseUrl/details/$schemeId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return SchemeDetails.fromJson(jsonData['data']);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching scheme details: $e');
      rethrow;
    }
  }

  /// Summarize text using Gemini API (1-2 sentences)
  Future<String> summarizeText(String text) async {
    try {
      print('📝 Summarizing text (${text.length} characters)');

      final url = Uri.parse('$baseUrl/summarize');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'text': text}),
          )
          .timeout(const Duration(seconds: 15));

      print('Summarize response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['summary'] != null) {
          print('✅ Successfully summarized text');
          return jsonData['summary'];
        }
      }

      // If summarization fails, return original text
      print('⚠️ Summarization failed, returning original text');
      return text;
    } catch (e) {
      print('Error summarizing text: $e');
      // Return original text if summarization fails
      return text;
    }
  }
}
