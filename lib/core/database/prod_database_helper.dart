import 'package:sqflite_common/sqlite_api.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/database_schema.dart';
import 'package:segundo_cogni/core/logger/app_logger.dart';

class ProdDatabaseHelper extends BaseDatabaseHelper {
  ProdDatabaseHelper._() : super('cognivoice_db.db');

  static final ProdDatabaseHelper instance = ProdDatabaseHelper._();

  @override
  Future<void> onCreate(Database db, int version) async {
    AppLogger.db('Creating production schema...');
    await DatabaseSchema.createAll(db);
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.db('Upgrading DB $oldVersion → $newVersion');
    await DatabaseSchema.dropAll(db);
    await DatabaseSchema.createAll(db);
  }
}
