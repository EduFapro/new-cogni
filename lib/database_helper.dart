import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/database_constants.dart';

import '../../features/evaluator/data/evaluator_constants.dart';
import '../../features/participant/data/participant_constants.dart';
import '../../features/evaluation/data/evaluation_constants.dart';
import '../../features/module/data/module_constants.dart';
import '../../features/task/data/task_constants.dart';
import '../../features/module_instance/data/module_instance_constants.dart';
import '../../features/task_instance/data/task_instance_constants.dart';
import '../../features/task_prompt/data/task_prompt_constants.dart';
import '../../features/recording_file/data/recording_file_constants.dart';

/// Handles database initialization, schema creation, and access.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;
  static String? _dbPath;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) {
      print('📂 Database already opened at: $_dbPath');
      return _db!;
    }

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    _dbPath = await databaseFactory.getDatabasesPath();
    final path = join(_dbPath!, DatabaseConfig.name);

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DatabaseConfig.version,
        onCreate: _onCreate,
      ),
    );

    // Enable FK constraints
    await _db!.execute("PRAGMA foreign_keys = ON;");
    print('✅ Database initialized at: $path');
    return _db!;
  }

  // Check if admin evaluator exists
  Future<bool> isAdminConfigured() async {
    final db = await this.db;
    var result = await db.query(
      Tables.evaluators,
      where: "${EvaluatorFields.isAdmin} = ?",
      whereArgs: [1],
    );
    return result.isNotEmpty;
  }

  /// Handles the creation of all tables (executed once)
  Future<void> _onCreate(Database db, int newVersion) async {
    print('🧱 Creating database schema (version $newVersion)...');

    try {
      // --- ORDER MATTERS: Foreign keys depend on prior tables ---
      await db.execute(scriptCreateTableEvaluators);
      await db.execute(scriptCreateTableParticipants);
      await db.execute(scriptCreateTableEvaluations);

      await db.execute(scriptCreateTableModules);
      await db.execute(scriptCreateTableTasks);

      await db.execute(scriptCreateTableModuleInstances);
      await db.execute(scriptCreateTableTaskInstances);

      await db.execute(scriptCreateTableTaskPrompts);
      await db.execute(scriptCreateTableRecordings);

      print('✅ All tables created successfully');
    } catch (e, st) {
      print('❌ Error creating tables: $e');
      print(st);
      rethrow;
    }
  }

  /// Optional utility to reset the database
  Future<void> resetDatabase() async {
    final path = join(_dbPath ?? await databaseFactory.getDatabasesPath(), DatabaseConfig.name);
    await databaseFactory.deleteDatabase(path);
    _db = null;
    print('🗑️ Database deleted at: $path');
  }
}
