import '../entities/user_session.dart';
import '../repositories/user_session_repository.dart';

/// Use case to save user session
class SaveUserSession {
  final UserSessionRepository repository;
  
  SaveUserSession(this.repository);
  
  Future<void> call(UserSession session) async {
    await repository.saveSession(session);
  }
}

/// Use case to get latest session
class GetLatestUserSession {
  final UserSessionRepository repository;
  
  GetLatestUserSession(this.repository);
  
  Future<UserSession?> call() async {
    return await repository.getLatestSession();
  }
}
