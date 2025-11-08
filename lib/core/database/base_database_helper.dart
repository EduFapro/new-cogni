import 'package:path/path.dart' as p;
import 'package:segundo_cogni/core/logger/app_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:meta/meta.dart';


abstract class BaseDatabaseHelper {
  BaseDatabaseHelper(this.dbName);

  final String dbName;
  Database? _db;

  int get dbVersion => 1;

  Future<void> onCreate(Database db, int version);
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      AppLogger.db('Database already initialized.');
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    AppLogger.db('Initializing database: $dbName');

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, dbName);
    AppLogger.db('Database path resolved: $path');

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: (db, version) async {
          AppLogger.db('Creating database schema.');
          await onCreate(db, version);
        },
        onUpgrade: (db, oldV, newV) async {
          AppLogger.db('Upgrading database from $oldV to $newV.');
          await onUpgrade(db, oldV, newV);
        },
      ),
    );

    AppLogger.db('Database opened successfully.');
    return db;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      AppLogger.db('Database closed and reset.');
    }
  }

  Future<void> deleteDb() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, dbName);
    await databaseFactory.deleteDatabase(path);
    _db = null;
    AppLogger.db('Database deleted: $dbName');
  }

  @protected
  Database? get dbInstance => _db;

  @protected
  void setDbInstance(Database? db) {
    _db = db;
  }

}
