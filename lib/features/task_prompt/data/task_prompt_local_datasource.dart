import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
    try {
      final db = await _db;
      return await db.insert(
        Tables.taskPrompts,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting TaskPrompt: $e');
      return null;
    }
  }

  Future<TaskPromptModel?> getById(int id) async {
    try {
      final db = await _db;
      final result = await db.query(
        Tables.taskPrompts,
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) return TaskPromptModel.fromMap(result.first);
      return null;
    } catch (e) {
      print('❌ Error fetching TaskPrompt by ID: $e');
      return null;
    }
  }

  Future<TaskPromptModel?> getByTaskId(int taskId) async {
    try {
      final db = await _db;
      final result = await db.query(
        Tables.taskPrompts,
        where: '${TaskPromptFields.taskId} = ?',
        whereArgs: [taskId],
      );
      if (result.isNotEmpty) return TaskPromptModel.fromMap(result.first);
      return null;
    } catch (e) {
      print('❌ Error fetching TaskPrompt by Task ID: $e');
      return null;
    }
  }

  Future<List<TaskPromptModel>> getAll() async {
    try {
      final db = await _db;
      final result = await db.query(Tables.taskPrompts);
      return result.map(TaskPromptModel.fromMap).toList();
    } catch (e) {
      print('❌ Error fetching all TaskPrompts: $e');
      return [];
    }
  }

  Future<int> update(TaskPromptModel model) async {
    try {
      final db = await _db;
      return await db.update(
        Tables.taskPrompts,
        model.toMap(),
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('❌ Error updating TaskPrompt: $e');
      return -1;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await _db;
      return await db.delete(
        Tables.taskPrompts,
        where: '${TaskPromptFields.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting TaskPrompt: $e');
      return -1;
    }
  }
}
