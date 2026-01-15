import '../entities/user_session.dart';

/// Repository interface for user session operations
abstract class UserSessionRepository {
  /// Save a new user session
  Future<void> saveSession(UserSession session);
  
  /// Get the most recent user session
  Future<UserSession?> getLatestSession();
  
  /// Get all user sessions
  Future<List<UserSession>> getAllSessions();
  
  /// Clear all sessions (for testing/reset)
  Future<void> clearAllSessions();
}
