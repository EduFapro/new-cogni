import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/constants/database_constants.dart';
import '../../../database_helper.dart';
import '../../task/data/task_constants.dart';
import '../../task_instance/data/task_instance_constants.dart';
import '../../task_instance/data/task_instance_model.dart';
import '../../../core/constants/enums/progress_status.dart';

/// Handles all SQLite operations for the `task_instances` table.
/// Responsible only for persistence — no business logic.
class TaskInstanceLocalDataSource {
  static final TaskInstanceLocalDataSource _instance =
  TaskInstanceLocalDataSource._internal();

  factory TaskInstanceLocalDataSource() => _instance;

  TaskInstanceLocalDataSource._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => dbHelper.database;

  Future<int?> create(TaskInstanceModel model) async {
    try {
      final db = await _db;
      return await db.insert(
        Tables.taskInstances,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting task instance: $e');
      return null;
    }
  }

  Future<TaskInstanceModel?> getTaskInstance(int id) async {
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.taskInstances,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return TaskInstanceModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching task instance by ID: $e');
      return null;
    }
  }

  Future<int> updateTaskInstance(TaskInstanceModel model) async {
    try {
      final db = await _db;
      return await db.update(
        Tables.taskInstances,
        model.toMap(),
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('❌ Error updating task instance: $e');
      return -1;
    }
  }

  Future<int> deleteTaskInstance(int id) async {
    try {
      final db = await _db;
      return await db.delete(
        Tables.taskInstances,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting task instance: $e');
      return -1;
    }
  }

  Future<List<TaskInstanceModel>> getAllTaskInstances() async {
    try {
      final db = await _db;
      final maps = await db.query(Tables.taskInstances);
      return maps.map(TaskInstanceModel.fromMap).toList();
    } catch (e) {
      print('❌ Error fetching all task instances: $e');
      return [];
    }
  }

  Future<List<TaskInstanceModel>> getTaskInstancesForModuleInstance(int moduleInstanceId) async {
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.taskInstances,
        where: '${TaskInstanceFields.moduleInstanceId} = ?',
        whereArgs: [moduleInstanceId],
      );
      return maps.map(TaskInstanceModel.fromMap).toList();
    } catch (e) {
      print('❌ Error fetching task instances for module instance: $e');
      return [];
    }
  }

  Future<int?> getNumberOfTaskInstances() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${Tables.taskInstances}');
      return result.first['count'] as int?;
    } catch (e) {
      print('❌ Error counting task instances: $e');
      return null;
    }
  }

  /// Retrieves the first pending task instance (status == 0).
  Future<TaskInstanceModel?> getFirstPendingTaskInstance() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('''
        SELECT ti.* FROM ${Tables.taskInstances} ti
        INNER JOIN ${Tables.tasks} t ON ti.${TaskInstanceFields.taskId} = t.${TaskFields.id}
        WHERE ti.${TaskInstanceFields.status} = 0
        ORDER BY t.${TaskFields.position} ASC
        LIMIT 1
      ''');
      if (result.isNotEmpty) {
        return TaskInstanceModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching first pending task instance: $e');
      return null;
    }
  }

  Future<int> markAsCompleted(int id, {String? duration}) async {
    try {
      final db = await _db;
      final map = {
        TaskInstanceFields.status: TaskStatus.completed.numericValue,
        if (duration != null) TaskInstanceFields.completingTime: duration,
      };
      return await db.update(
        Tables.taskInstances,
        map,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error marking task as completed: $e');
      return -1;
    }
  }
}
