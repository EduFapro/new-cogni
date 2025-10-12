import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/constants/database_constants.dart';
import '../../../database_helper.dart';
import '../../task_prompt/data/task_prompt_constants.dart';
import '../../task_prompt/data/task_prompt_model.dart';

class TaskPromptLocalDataSource {
  static final TaskPromptLocalDataSource _instance =
  TaskPromptLocalDataSource._internal();

  factory TaskPromptLocalDataSource() => _instance;

  TaskPromptLocalDataSource._internal();

  final dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => dbHelper.database;

  Future<int?> insert(TaskPromptModel model) async {
    AppLogger.db('Inserting TaskPrompt for taskId=${model.taskId}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.taskPrompts,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('TaskPrompt inserted (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting TaskPrompt', e, s);
      return null;
    }
  }

  Future<TaskPromptModel?> getById(int id) async {
    AppLogger.db('Fetching TaskPrompt by ID=$id');
    try {
      final db = await _db;
      final result = await db.query(
        Tables.taskPrompts,
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? TaskPromptModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching TaskPrompt by ID=$id', e, s);
      return null;
    }
  }

  Future<TaskPromptModel?> getByTaskId(int taskId) async {
    AppLogger.db('Fetching TaskPrompt by taskId=$taskId');
    try {
      final db = await _db;
      final result = await db.query(
        Tables.taskPrompts,
        where: '${TaskPromptFields.taskId} = ?',
        whereArgs: [taskId],
      );
      return result.isNotEmpty ? TaskPromptModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching TaskPrompt by taskId=$taskId', e, s);
      return null;
    }
  }

  Future<List<TaskPromptModel>> getAll() async {
    AppLogger.db('Fetching all TaskPrompts');
    try {
      final db = await _db;
      final result = await db.query(Tables.taskPrompts);
      AppLogger.db('Fetched ${result.length} TaskPrompts');
      return result.map(TaskPromptModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching all TaskPrompts', e, s);
      return [];
    }
  }

  Future<int> update(TaskPromptModel model) async {
    AppLogger.db('Updating TaskPrompt ID=${model.id}');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.taskPrompts,
        model.toMap(),
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [model.id],
      );
      AppLogger.db('Updated $rows TaskPrompt(s)');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error updating TaskPrompt ID=${model.id}', e, s);
      return 0;
    }
  }

  Future<int> delete(int id) async {
    AppLogger.db('Deleting TaskPrompt ID=$id');
    try {
      final db = await _db;
      final count = await db.delete(
        Tables.taskPrompts,
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db('Deleted $count TaskPrompt(s)');
      return count;
    } catch (e, s) {
      AppLogger.error('Error deleting TaskPrompt ID=$id', e, s);
      return 0;
    }
  }
}
