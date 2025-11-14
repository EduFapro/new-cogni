// data/module_local_datasource.dart

import 'package:sqflite_common/sqlite_api.dart';

import '../../../core/constants/database_constants.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import 'module_model.dart';
import 'module_constants.dart';

class ModuleLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  ModuleLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModule(ModuleModel model) async {
    AppLogger.db('[ModuleLocalDataSource] Inserting module "${model.title}"');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.modules,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('[ModuleLocalDataSource] Inserted with ID=$id');
      return id;
    } catch (e, s) {
      AppLogger.error('[ModuleLocalDataSource] Failed to insert module', e, s);
      return null;
    }
  }

  Future<List<ModuleModel>> getAllModules() async {
    final db = await _db;
    final rows = await db.query(Tables.modules);
    return rows.map(ModuleModel.fromMap).toList();
  }

  Future<ModuleModel?> getModuleById(int id) async {
    final db = await _db;
    final rows = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
    return rows.isNotEmpty ? ModuleModel.fromMap(rows.first) : null;
  }

  Future<ModuleModel?> getModuleByTitle(String title) async {
    final db = await _db;
    final rows = await db.query(
      Tables.modules,
      where: '${ModuleFields.title} = ?',
      whereArgs: [title],
    );
    return rows.isNotEmpty ? ModuleModel.fromMap(rows.first) : null;
  }

  Future<int> updateModule(ModuleModel model) async {
    final db = await _db;
    return await db.update(
      Tables.modules,
      model.toMap(),
      where: '${ModuleFields.id} = ?',
      whereArgs: [model.moduleID],
    );
  }

  Future<int> deleteModule(int id) async {
    final db = await _db;
    return await db.delete(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getNumberOfModules() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM ${Tables.modules}');
    final count = result.first['count'];
    return count is int ? count : int.tryParse(count.toString()) ?? 0;
  }


  Future<bool> exists(int id) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
