import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/constants/database_constants.dart';
import 'task_constants.dart';
import 'task_model.dart';

class TaskLocalDataSource {
  final dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertTask(TaskModel task) async {
    AppLogger.db('Inserting task: ${task.title}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.tasks,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Task inserted successfully (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting task: ${task.title}', e, s);
      return null;
    }
  }

  Future<TaskModel?> getTaskById(int id) async {
    AppLogger.db('Fetching task by ID=$id');
    try {
      final db = await _db;
      final result = await db.query(
        Tables.tasks,
        where: '${TaskFields.id} = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        AppLogger.db('Task found (ID=$id)');
        return TaskModel.fromMap(result.first);
      }
      AppLogger.db('No task found (ID=$id)');
      return null;
    } catch (e, s) {
      AppLogger.error('Error fetching task by ID=$id', e, s);
      return null;
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    AppLogger.db('Fetching all tasks');
    try {
      final db = await _db;
      final maps = await db.query(Tables.tasks);
      AppLogger.db('Fetched ${maps.length} tasks');
      return maps.map(TaskModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching all tasks', e, s);
      return [];
    }
  }

  Future<List<TaskModel>> getTasksByModuleId(int moduleId) async {
    AppLogger.db('Fetching tasks for moduleId=$moduleId');
    try {
      final db = await _db;
      final maps = await db.query(
        Tables.tasks,
        where: '${TaskFields.moduleId} = ?',
        whereArgs: [moduleId],
      );
      AppLogger.db('Fetched ${maps.length} tasks for moduleId=$moduleId');
      return maps.map(TaskModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching tasks for moduleId=$moduleId', e, s);
      return [];
    }
  }

  Future<int> updateTask(TaskModel task) async {
    AppLogger.db('Updating task ID=${task.taskID}');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.tasks,
        task.toMap(),
        where: '${TaskFields.id} = ?',
        whereArgs: [task.taskID],
      );
      AppLogger.db('Updated $rows task(s) for ID=${task.taskID}');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error updating task ID=${task.taskID}', e, s);
      return 0;
    }
  }

  Future<int> deleteTask(int id) async {
    AppLogger.db('Deleting task ID=$id');
    try {
      final db = await _db;
      final count = await db.delete(
        Tables.tasks,
        where: '${TaskFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db('Deleted $count task(s)');
      return count;
    } catch (e, s) {
      AppLogger.error('Error deleting task ID=$id', e, s);
      return 0;
    }
  }

  Future<bool> exists(String taskId) async {
    final db = await _db;
    final result = await db.query(
      Tables.tasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
