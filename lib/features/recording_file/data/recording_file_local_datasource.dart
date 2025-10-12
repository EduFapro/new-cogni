import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database_helper.dart';
import '../../recording_file/data/recording_file_constants.dart';
import '../../recording_file/data/recording_file_model.dart';
import '../../../core/logger/app_logger.dart';

class RecordingFileLocalDataSource {
  static final RecordingFileLocalDataSource _instance =
  RecordingFileLocalDataSource._internal();

  factory RecordingFileLocalDataSource() => _instance;

  RecordingFileLocalDataSource._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insert(RecordingFileModel model) async {
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.recordings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Inserted RecordingFile (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting RecordingFile', e, s);
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
      return result.isNotEmpty ? RecordingFileModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching RecordingFile by ID: $id', e, s);
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
      return result.isNotEmpty ? RecordingFileModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching RecordingFile by TaskInstanceId: $taskInstanceId', e, s);
      return null;
    }
  }

  Future<List<RecordingFileModel>> getAll() async {
    try {
      final db = await _db;
      final result = await db.query(Tables.recordings);
      return result.map(RecordingFileModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching all RecordingFiles', e, s);
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
    } catch (e, s) {
      AppLogger.error('Error updating RecordingFile ID=${model.id}', e, s);
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
    } catch (e, s) {
      AppLogger.error('Error deleting RecordingFile ID=$id', e, s);
      return -1;
    }
  }
}
