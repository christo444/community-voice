import '../model/scheme.dart';
import '../../data/datasources/scheme_datasource.dart';

class SchemeRepository {
  final SchemeDatasource _datasource = SchemeDatasource();

  /// Get schemes matched for a specific user
  Future<List<Scheme>> getMatchedSchemes(String phoneNumber,
      {bool refresh = false}) async {
    return await _datasource.getMatchedSchemes(phoneNumber, refresh: refresh);
  }

  /// Get all schemes from the database unconditionally
  Future<List<Scheme>> getAllSchemes() async {
    return await _datasource.getAllSchemes();
  }

  /// Get complete details for a specific scheme
  Future<SchemeDetails?> getSchemeDetails(String schemeId) async {
    return await _datasource.getSchemeDetails(schemeId);
  }

  /// Summarize text using Gemini API (max 3 sentences)
  Future<String> summarizeText(String text) async {
    return await _datasource.summarizeText(text);
  }
}
