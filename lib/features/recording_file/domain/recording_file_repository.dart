import 'recording_file_entity.dart';

abstract class RecordingFileRepository {
  Future<int?> insert(RecordingFileEntity entity);
  Future<RecordingFileEntity?> getById(int id);
  Future<RecordingFileEntity?> getByTaskInstanceId(int taskInstanceId);
  Future<List<RecordingFileEntity>> getAll();
  Future<int> update(RecordingFileEntity entity);
  Future<int> delete(int id);
}
