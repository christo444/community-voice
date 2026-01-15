import '../entities/scheme.dart';

/// Repository interface for scheme data operations
abstract class SchemeRepository {
  /// Fetch schemes from remote server and sync to local database
  Future<void> syncSchemesFromRemote();
  
  /// Get all active schemes from local database
  Future<List<Scheme>> getAllSchemes();
  
  /// Get active schemes only
  Future<List<Scheme>> getActiveSchemes();
  
  /// Get scheme by ID
  Future<Scheme?> getSchemeById(String schemeId);
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();
}
