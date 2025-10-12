import 'package:sqflite_common/sqlite_api.dart';

import '../../../core/constants/database_constants.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../database_helper.dart';
import 'module_instance_constants.dart';
import 'module_instance_model.dart';

class ModuleInstanceLocalDataSource {
  final dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModuleInstance(ModuleInstanceModel instance) async {
    final db = await _db;
    return await db.insert(
      Tables.moduleInstances,
      instance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ModuleInstanceModel?> getModuleInstanceById(int id) async {
    final db = await _db;
    final maps = await db.query(
      Tables.moduleInstances,
      where: '${ModuleInstanceFields.id} = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? ModuleInstanceModel.fromMap(maps.first) : null;
  }

  Future<List<ModuleInstanceModel>> getAllModuleInstances() async {
    final db = await _db;
    final maps = await db.query(Tables.moduleInstances);
    return maps.map((e) => ModuleInstanceModel.fromMap(e)).toList();
  }

  Future<List<ModuleInstanceModel>> getModuleInstancesByEvaluationId(
      int evaluationId) async {
    final db = await _db;
    final maps = await db.query(
      Tables.moduleInstances,
      where: '${ModuleInstanceFields.evaluationId} = ?',
      whereArgs: [evaluationId],
    );
    return maps.map((e) => ModuleInstanceModel.fromMap(e)).toList();
  }

  Future<int> updateModuleInstance(ModuleInstanceModel instance) async {
    final db = await _db;
    return await db.update(
      Tables.moduleInstances,
      instance.toMap(),
      where: '${ModuleInstanceFields.id} = ?',
      whereArgs: [instance.id],
    );
  }

  Future<int> deleteModuleInstance(int id) async {
    final db = await _db;
    return await db.delete(
      Tables.moduleInstances,
      where: '${ModuleInstanceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM ${Tables.moduleInstances}');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> setStatus(int instanceId, ModuleStatus status) async {
    final db = await _db;
    return await db.update(
      Tables.moduleInstances,
      {ModuleInstanceFields.status: status.numericValue},
      where: '${ModuleInstanceFields.id} = ?',
      whereArgs: [instanceId],
    );
  }
}
