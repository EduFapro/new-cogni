import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import 'module_constants.dart';
import 'module_model.dart';

class ModuleLocalDataSource {
  final BaseDatabaseHelper dbHelper;
  ModuleLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModule(ModuleModel module) async {
    AppLogger.db('Inserting module: ${module.title}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.modules,
        module.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Module inserted successfully (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting module ${module.title}', e, s);
      return null;
    }
  }

  Future<List<ModuleModel>> getAllModules() async {
    final db = await _db;
    final maps = await db.query(Tables.modules);
    return maps.map(ModuleModel.fromMap).toList();
  }

  Future<ModuleModel?> getModuleById(int id) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
  }

  Future<ModuleModel?> getModuleByTitle(String title) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.title} = ?',
      whereArgs: [title],
    );
    return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
  }

  Future<int> updateModule(ModuleModel module) async {
    final db = await _db;
    return db.update(
      Tables.modules,
      module.toMap(),
      where: '${ModuleFields.id} = ?',
      whereArgs: [module.moduleID],
    );
  }

  Future<int> deleteModule(int id) async {
    final db = await _db;
    return db.delete(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getNumberOfModules() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM ${Tables.modules}');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<bool> exists(String moduleId) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [moduleId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
