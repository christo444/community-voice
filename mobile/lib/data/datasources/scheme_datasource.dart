import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../../domain/model/scheme.dart';

class SchemeDatasource {
  // Using localhost via adb port forwarding (adb reverse tcp:5000 tcp:5000)
  // This maps localhost:5000 on emulator to localhost:5000 on host machine
  static const String baseUrl = 'http://localhost:5000/api/schemes';

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
          final schemes = (jsonData['data']['matched_schemes'] as List)
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
      print('2. Port forwarding is active (adb reverse tcp:5000 tcp:5000)');
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
