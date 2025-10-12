import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/constants/database_constants.dart';
import '../../../database_helper.dart';
import '../../recording_file/data/recording_file_constants.dart';
import '../../recording_file/data/recording_file_model.dart';

class RecordingFileLocalDataSource {
  static final RecordingFileLocalDataSource _instance =
  RecordingFileLocalDataSource._internal();

  factory RecordingFileLocalDataSource() => _instance;

  RecordingFileLocalDataSource._internal();

  final dbHelper = DatabaseHelper();

  Future<Database> get _db async => dbHelper.db;

  Future<int?> insert(RecordingFileModel model) async {
    try {
      final db = await _db;
      return await db.insert(
        Tables.recordings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting RecordingFile: $e');
      return null;
    }
  }

  Future<RecordingFileModel?> getById(int id) async {
    try {
      final db = await _db;
      final result = await db.query(
        Tables.recordings,
        where: '${RecordingFileFields.id} = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return RecordingFileModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching RecordingFile by ID: $e');
      return null;
    }
  }

  Future<RecordingFileModel?> getByTaskInstanceId(int taskInstanceId) async {
    try {
      final db = await _db;
      final result = await db.query(
        Tables.recordings,
        where: '${RecordingFileFields.taskInstanceId} = ?',
        whereArgs: [taskInstanceId],
      );
      if (result.isNotEmpty) {
        return RecordingFileModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching RecordingFile by TaskInstanceId: $e');
      return null;
    }
  }

  Future<List<RecordingFileModel>> getAll() async {
    try {
      final db = await _db;
      final result = await db.query(Tables.recordings);
      return result.map(RecordingFileModel.fromMap).toList();
    } catch (e) {
      print('❌ Error fetching all RecordingFiles: $e');
      return [];
    }
  }

  Future<int> update(RecordingFileModel model) async {
    try {
      final db = await _db;
      return await db.update(
        Tables.recordings,
        model.toMap(),
        where: '${RecordingFileFields.id} = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('❌ Error updating RecordingFile: $e');
      return -1;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await _db;
      return await db.delete(
        Tables.recordings,
        where: '${RecordingFileFields.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting RecordingFile: $e');
      return -1;
    }
  }
}
