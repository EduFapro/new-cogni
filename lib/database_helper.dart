import 'package:path/path.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/logger/app_logger.dart';
import 'features/evaluation/data/evaluation_constants.dart';
import 'features/evaluator/data/evaluator_constants.dart';
import 'features/module/data/module_constants.dart';
import 'features/participant/data/participant_constants.dart';
import 'features/task/data/task_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    AppLogger.db('Initializing database: $filePath');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    AppLogger.db('Creating database schema, version=$version');
    try {
      await db.execute(scriptCreateTableEvaluators);
      await db.execute(scriptCreateTableParticipants);
      await db.execute(scriptCreateTableEvaluations);

      await db.execute(scriptCreateTableModules);
      await db.execute(scriptCreateTableTasks);
      await DatabaseSeeder().run();
    } catch (e, s) {
      AppLogger.error('Error creating DB schema', e, s);
    }
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await instance.database;
    AppLogger.db('Inserting into $table: $values');
    try {
      final id = await db.insert(table, values);
      AppLogger.db('Insert success [$table]: id=$id');
      return id;
    } catch (e, s) {
      AppLogger.error('Insert failed [$table]', e, s);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    AppLogger.db('Querying table=$table where=$where args=$whereArgs');
    try {
      final result = await db.query(table, where: where, whereArgs: whereArgs);
      AppLogger.db('Query success [$table]: ${result.length} rows');
      return result;
    } catch (e, s) {
      AppLogger.error('Query failed [$table]', e, s);
      rethrow;
    }
  }

  Future<int> update(String table, Map<String, dynamic> values,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    AppLogger.db('Updating $table set=$values where=$where');
    try {
      final count = await db.update(table, values, where: where, whereArgs: whereArgs);
      AppLogger.db('Update success [$table]: $count rows affected');
      return count;
    } catch (e, s) {
      AppLogger.error('Update failed [$table]', e, s);
      rethrow;
    }
  }

  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    AppLogger.db('Deleting from $table where=$where');
    try {
      final count = await db.delete(table, where: where, whereArgs: whereArgs);
      AppLogger.db('Delete success [$table]: $count rows removed');
      return count;
    } catch (e, s) {
      AppLogger.error('Delete failed [$table]', e, s);
      rethrow;
    }
  }
}
