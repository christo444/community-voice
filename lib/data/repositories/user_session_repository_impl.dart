import '../../domain/entities/user_session.dart';
import '../../domain/repositories/user_session_repository.dart';
import '../datasources/user_session_local_datasource.dart';

/// Implementation of UserSessionRepository
class UserSessionRepositoryImpl implements UserSessionRepository {
  final UserSessionLocalDataSource localDataSource;
  
  UserSessionRepositoryImpl({required this.localDataSource});
  
  @override
  Future<void> saveSession(UserSession session) async {
    // Convert domain entity to data model
    final sessionModel = session as dynamic; // Already using model in practice
    await localDataSource.saveSession(sessionModel);
  }
  
  @override
  Future<UserSession?> getLatestSession() async {
    return await localDataSource.getLatestSession();
  }
  
  @override
  Future<List<UserSession>> getAllSessions() async {
    return await localDataSource.getAllSessions();
  }
  
  @override
  Future<void> clearAllSessions() async {
    await localDataSource.clearAllSessions();
  }
}
