import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// SQLite database helper - Singleton pattern
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  
  DatabaseHelper._();
  
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create schemes table
    await db.execute('''
      CREATE TABLE ${AppConstants.schemesTable} (
        scheme_id TEXT PRIMARY KEY,
        scheme_name TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        description TEXT,
        benefits TEXT,
        min_age INTEGER,
        max_age INTEGER,
        income_max INTEGER,
        categories TEXT,
        gender TEXT,
        is_disabled INTEGER DEFAULT 0,
        is_bpl INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Create user_sessions table
    await db.execute('''
      CREATE TABLE ${AppConstants.userSessionsTable} (
        session_id TEXT PRIMARY KEY,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        income INTEGER NOT NULL,
        category TEXT NOT NULL,
        is_disabled INTEGER NOT NULL DEFAULT 0,
        is_bpl INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    
    // Create metadata table for sync tracking
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database migrations in future versions
  }
  
  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.schemesTable);
    await db.delete(AppConstants.userSessionsTable);
    await db.delete('metadata');
  }
  
  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
