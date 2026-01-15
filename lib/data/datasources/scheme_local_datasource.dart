import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/database_helper.dart';
import '../models/scheme_model.dart';

/// Local data source for schemes using SQLite
class SchemeLocalDataSource {
  final DatabaseHelper _dbHelper;
  
  SchemeLocalDataSource(this._dbHelper);
  
  /// Insert or update schemes in local database
  Future<void> insertSchemes(List<SchemeModel> schemes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    
    for (final scheme in schemes) {
      batch.insert(
        AppConstants.schemesTable,
        scheme.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  /// Get all schemes from local database
  Future<List<SchemeModel>> getAllSchemes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.schemesTable);
    
    return maps.map((map) => SchemeModel.fromDbMap(map)).toList();
  }
  
  /// Get only active schemes
  Future<List<SchemeModel>> getActiveSchemes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.schemesTable,
      where: 'active = ?',
      whereArgs: [1],
    );
    
    return maps.map((map) => SchemeModel.fromDbMap(map)).toList();
  }
  
  /// Get scheme by ID
  Future<SchemeModel?> getSchemeById(String schemeId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.schemesTable,
      where: 'scheme_id = ?',
      whereArgs: [schemeId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return SchemeModel.fromDbMap(maps.first);
  }
  
  /// Save last sync timestamp
  Future<void> saveLastSyncTime(DateTime timestamp) async {
    final db = await _dbHelper.database;
    await db.insert(
      'metadata',
      {
        'key': 'last_sync',
        'value': timestamp.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: ['last_sync'],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return DateTime.parse(maps.first['value'] as String);
  }
}
