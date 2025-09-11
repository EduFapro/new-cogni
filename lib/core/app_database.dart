import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'cogni.db');

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE evaluators (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              surname TEXT,
              email TEXT,
              birthDate TEXT,
              specialty TEXT,
              cpfOrNif TEXT,
              username TEXT,
              password TEXT,
              firstLogin INTEGER,
              isAdmin INTEGER
            )
          ''');
        },
      ),
    );
    return _db!;
  }
}
