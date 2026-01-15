import '../../core/constants/app_constants.dart';
import '../../core/services/database_helper.dart';
import '../models/user_session_model.dart';

/// Local data source for user sessions
class UserSessionLocalDataSource {
  final DatabaseHelper _dbHelper;
  
  UserSessionLocalDataSource(this._dbHelper);
  
  /// Save user session
  Future<void> saveSession(UserSessionModel session) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.userSessionsTable,
      session.toDbMap(),
    );
  }
  
  /// Get latest session
  Future<UserSessionModel?> getLatestSession() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.userSessionsTable,
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return UserSessionModel.fromDbMap(maps.first);
  }
  
  /// Get all sessions
  Future<List<UserSessionModel>> getAllSessions() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.userSessionsTable,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => UserSessionModel.fromDbMap(map)).toList();
  }
  
  /// Clear all sessions
  Future<void> clearAllSessions() async {
    final db = await _dbHelper.database;
    await db.delete(AppConstants.userSessionsTable);
  }
}
