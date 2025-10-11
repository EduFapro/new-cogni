import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../database_helper.dart';
import 'task_constants.dart';
import 'task_model.dart';

class TaskLocalDataSource {
  final dbHelper = DatabaseHelper();

  Future<Database> get _db async => dbHelper.db;

  Future<int?> insertTask(TaskModel task) async {
    final db = await _db;
    return db.insert(
      Tables.tasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TaskModel?> getTaskById(int id) async {
    final db = await _db;
    final result = await db.query(
      Tables.tasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? TaskModel.fromMap(result.first) : null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _db;
    final maps = await db.query(Tables.tasks);
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getTasksByModuleId(int moduleId) async {
    final db = await _db;
    final maps = await db.query(
      Tables.tasks,
      where: '${TaskFields.moduleId} = ?',
      whereArgs: [moduleId],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await _db;
    return db.update(
      Tables.tasks,
      task.toMap(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _db;
    return db.delete(
      Tables.tasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
  }
}
