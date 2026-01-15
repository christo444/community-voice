import '../../domain/entities/scheme.dart';
import '../../domain/repositories/scheme_repository.dart';
import '../datasources/scheme_local_datasource.dart';
import '../datasources/scheme_remote_datasource.dart';

/// Implementation of SchemeRepository
class SchemeRepositoryImpl implements SchemeRepository {
  final SchemeRemoteDataSource remoteDataSource;
  final SchemeLocalDataSource localDataSource;
  
  SchemeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<void> syncSchemesFromRemote() async {
    // Fetch from remote (or mock data)
    final schemes = await remoteDataSource.fetchSchemes();
    
    // Save to local database
    await localDataSource.insertSchemes(schemes);
    
    // Update last sync time
    await localDataSource.saveLastSyncTime(DateTime.now());
  }
  
  @override
  Future<List<Scheme>> getAllSchemes() async {
    return await localDataSource.getAllSchemes();
  }
  
  @override
  Future<List<Scheme>> getActiveSchemes() async {
    return await localDataSource.getActiveSchemes();
  }
  
  @override
  Future<Scheme?> getSchemeById(String schemeId) async {
    return await localDataSource.getSchemeById(schemeId);
  }
  
  @override
  Future<DateTime?> getLastSyncTime() async {
    return await localDataSource.getLastSyncTime();
  }
}
