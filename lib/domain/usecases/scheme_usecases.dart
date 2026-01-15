import '../entities/scheme.dart';
import '../repositories/scheme_repository.dart';

/// Use case to sync schemes from remote server
class SyncSchemes {
  final SchemeRepository repository;
  
  SyncSchemes(this.repository);
  
  Future<void> call() async {
    await repository.syncSchemesFromRemote();
  }
}

/// Use case to get all active schemes
class GetActiveSchemes {
  final SchemeRepository repository;
  
  GetActiveSchemes(this.repository);
  
  Future<List<Scheme>> call() async {
    return await repository.getActiveSchemes();
  }
}
