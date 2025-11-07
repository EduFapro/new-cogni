import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import 'module_instance_constants.dart';
import 'module_instance_model.dart';

class ModuleInstanceLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  ModuleInstanceLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModuleInstance(ModuleInstanceModel instance) async {
    AppLogger.db('Inserting module instance for evaluationId=${instance.evaluationId}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.moduleInstances,
        instance.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Module instance inserted (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting module instance', e, s);
      return null;
    }
  }

  Future<ModuleInstanceModel?> getModuleInstanceById(int id) async {
    AppLogger.db('Fetching module instance ID=$id');
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.moduleInstances,
        where: '${ModuleInstanceFields.id} = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty ? ModuleInstanceModel.fromMap(maps.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching module instance ID=$id', e, s);
      return null;
    }
  }

  Future<List<ModuleInstanceModel>> getAllModuleInstances() async {
    AppLogger.db('Fetching all module instances');
    try {
      final db = await _db;
      final maps = await db.query(Tables.moduleInstances);
      AppLogger.db('Fetched ${maps.length} module instances');
      return maps.map(ModuleInstanceModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching all module instances', e, s);
      return [];
    }
  }

  Future<List<ModuleInstanceModel>> getModuleInstancesByEvaluationId(
      int evaluationId) async {
    AppLogger.db('Fetching module instances by evaluationId=$evaluationId');
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.moduleInstances,
        where: '${ModuleInstanceFields.evaluationId} = ?',
        whereArgs: [evaluationId],
      );
      AppLogger.db('Fetched ${maps.length} instances for evaluationId=$evaluationId');
      return maps.map(ModuleInstanceModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching instances by evaluationId=$evaluationId', e, s);
      return [];
    }
  }

  Future<int> updateModuleInstance(ModuleInstanceModel instance) async {
    AppLogger.db('Updating module instance ID=${instance.id}');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.moduleInstances,
        instance.toMap(),
        where: '${ModuleInstanceFields.id} = ?',
        whereArgs: [instance.id],
      );
      AppLogger.db('Updated $rows row(s)');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error updating module instance ID=${instance.id}', e, s);
      return 0;
    }
  }

  Future<int> deleteModuleInstance(int id) async {
    AppLogger.db('Deleting module instance ID=$id');
    try {
      final db = await _db;
      final count = await db.delete(
        Tables.moduleInstances,
        where: '${ModuleInstanceFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db('Deleted $count module instance(s)');
      return count;
    } catch (e, s) {
      AppLogger.error('Error deleting module instance ID=$id', e, s);
      return 0;
    }
  }

  Future<int> getCount() async {
    AppLogger.db('Counting module instances');
    try {
      final db = await _db;
      final result = await db
          .rawQuery('SELECT COUNT(*) AS count FROM ${Tables.moduleInstances}');
      final count = (result.first['count'] as int?) ?? 0;
      AppLogger.db('Module instance count: $count');
      return count;
    } catch (e, s) {
      AppLogger.error('Error counting module instances', e, s);
      return 0;
    }
  }

  Future<int> setStatus(int instanceId, ModuleStatus status) async {
    AppLogger.db('Setting status=${status.name} for moduleInstanceId=$instanceId');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.moduleInstances,
        {ModuleInstanceFields.status: status.numericValue},
        where: '${ModuleInstanceFields.id} = ?',
        whereArgs: [instanceId],
      );
      AppLogger.db('Updated status for $rows row(s)');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error setting status for moduleInstanceId=$instanceId', e, s);
      return 0;
    }
  }
}
