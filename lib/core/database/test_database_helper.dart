import 'package:segundo_cogni/core/database/database_schema.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';

import '../logger/app_logger.dart';

class TestDatabaseHelper extends BaseDatabaseHelper {
  TestDatabaseHelper._() : super('test_cognivoice_db.db');
  static final TestDatabaseHelper instance = TestDatabaseHelper._();

  @override
  Future<Database> _initDB() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    AppLogger.db('Creating in-memory test database...');
    return await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: (db, version) async => await onCreate(db, version),
      ),
    );
  }

  @override
  Future<void> onCreate(Database db, int version) async {
    await DatabaseSchema.createAll(db);
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    await DatabaseSchema.createAll(db);
  }
}
