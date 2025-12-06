import 'package:sqflite_common/sqlite_api.dart';

import '../../../core/constants/database_constants.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../../task/data/task_constants.dart';
import '../../task_instance/data/task_instance_constants.dart';
import '../../task_instance/data/task_instance_model.dart';

class TaskInstanceLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  TaskInstanceLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> create(TaskInstanceModel model) async {
    AppLogger.db('Creating task instance for taskId=${model.taskId}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.taskInstances,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Task instance created successfully (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error creating task instance', e, s);
      return null;
    }
  }

  Future<TaskInstanceModel?> getTaskInstance(int id) async {
    AppLogger.db('Fetching task instance ID=$id');
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.taskInstances,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        AppLogger.db('Task instance found (ID=$id)');
        return TaskInstanceModel.fromMap(maps.first);
      }
      AppLogger.db('No task instance found (ID=$id)');
      return null;
    } catch (e, s) {
      AppLogger.error('Error fetching task instance ID=$id', e, s);
      return null;
    }
  }

  Future<int> updateTaskInstance(TaskInstanceModel model) async {
    AppLogger.db('Updating task instance ID=${model.id}');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.taskInstances,
        model.toMap(),
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [model.id],
      );
      AppLogger.db('Updated $rows task instance(s)');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error updating task instance ID=${model.id}', e, s);
      return 0;
    }
  }

  Future<int> deleteTaskInstance(int id) async {
    AppLogger.db('Deleting task instance ID=$id');
    try {
      final db = await _db;
      final count = await db.delete(
        Tables.taskInstances,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db('Deleted $count task instance(s)');
      return count;
    } catch (e, s) {
      AppLogger.error('Error deleting task instance ID=$id', e, s);
      return 0;
    }
  }

  Future<List<TaskInstanceModel>> getAllTaskInstances() async {
    AppLogger.db('Fetching all task instances');
    try {
      final db = await _db;
      final maps = await db.query(Tables.taskInstances);
      AppLogger.db('Fetched ${maps.length} task instances');
      return maps.map(TaskInstanceModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching all task instances', e, s);
      return [];
    }
  }

  Future<List<TaskInstanceModel>> getTaskInstancesForModuleInstance(
    int moduleInstanceId,
  ) async {
    AppLogger.db(
      'Fetching task instances for moduleInstanceId=$moduleInstanceId',
    );
    try {
      final db = await _db;
      final result = await db.rawQuery(
        '''
        SELECT ti.*, t.${TaskFields.title} as task_title
        FROM ${Tables.taskInstances} ti
        INNER JOIN ${Tables.tasks} t ON ti.${TaskInstanceFields.taskId} = t.${TaskFields.id}
        WHERE ti.${TaskInstanceFields.moduleInstanceId} = ?
      ''',
        [moduleInstanceId],
      );

      AppLogger.db(
        'Fetched ${result.length} task instances for moduleInstanceId=$moduleInstanceId',
      );
      return result.map(TaskInstanceModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error(
        'Error fetching task instances for moduleInstanceId=$moduleInstanceId',
        e,
        s,
      );
      return [];
    }
  }

  Future<int?> getNumberOfTaskInstances() async {
    AppLogger.db('Counting task instances');
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${Tables.taskInstances}',
      );
      final count = result.first['count'] as int?;
      AppLogger.db('Task instance count: $count');
      return count;
    } catch (e, s) {
      AppLogger.error('Error counting task instances', e, s);
      return null;
    }
  }

  Future<TaskInstanceModel?> getFirstPendingTaskInstance() async {
    AppLogger.db('Fetching first pending task instance');
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
        AppLogger.db(
          'Found pending task instance ID=${result.first[TaskInstanceFields.id]}',
        );
        return TaskInstanceModel.fromMap(result.first);
      }
      AppLogger.db('No pending task instance found');
      return null;
    } catch (e, s) {
      AppLogger.error('Error fetching first pending task instance', e, s);
      return null;
    }
  }

  Future<void> markAsCompleted(int id, {String? duration}) async {
    AppLogger.db('Marking task instance ID=$id as completed');
    try {
      final db = await _db;
      final map = {
        TaskInstanceFields.status: TaskStatus.completed.numericValue,
        if (duration != null) TaskInstanceFields.completingTime: duration,
      };
      final rows = await db.update(
        Tables.taskInstances,
        map,
        where: '${TaskInstanceFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db(
        'Task instance ID=$id marked as completed ($rows row(s) affected)',
      );
    } catch (e, s) {
      AppLogger.db('⛔ Error marking task instance ID=$id as completed');
      AppLogger.error('⛔ DB ERROR marking task instance', e, s);
    }
  }
}
