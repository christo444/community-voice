import '../model/scheme.dart';
import '../../data/datasources/scheme_datasource.dart';

class SchemeRepository {
  final SchemeDatasource _datasource = SchemeDatasource();

  /// Get schemes matched for a specific user
  Future<List<Scheme>> getMatchedSchemes(String phoneNumber) async {
    return await _datasource.getMatchedSchemes(phoneNumber);
  }

  /// Get complete details for a specific scheme
  Future<SchemeDetails?> getSchemeDetails(String schemeId) async {
    return await _datasource.getSchemeDetails(schemeId);
  }
}
