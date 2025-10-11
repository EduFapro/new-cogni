import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../features/evaluator/data/evaluator_constants.dart';
import 'constants/database_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, DatabaseConfig.name);

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DatabaseConfig.version,
        onCreate: (db, version) async {
          await db.execute(scriptCreateTableEvaluators);
        },
      ),
    );
    return _db!;
  }
}
