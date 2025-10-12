import '../../recording_file/domain/recording_file_entity.dart';
import '../../recording_file/domain/recording_file_repository.dart';
import '../../recording_file/data/recording_file_model.dart';
import '../../recording_file/data/recording_file_local_datasource.dart';

class RecordingFileRepositoryImpl implements RecordingFileRepository {
  final RecordingFileLocalDataSource localDataSource;

  RecordingFileRepositoryImpl({required this.localDataSource});

  @override
  Future<int?> insert(RecordingFileEntity entity) async {
    final model = RecordingFileModel.fromEntity(entity);
    return await localDataSource.insert(model);
  }

  @override
  Future<RecordingFileEntity?> getById(int id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<RecordingFileEntity?> getByTaskInstanceId(int taskInstanceId) async {
    final model = await localDataSource.getByTaskInstanceId(taskInstanceId);
    return model?.toEntity();
  }

  @override
  Future<List<RecordingFileEntity>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> update(RecordingFileEntity entity) async {
    final model = RecordingFileModel.fromEntity(entity);
    return await localDataSource.update(model);
  }

  @override
  Future<int> delete(int id) async {
    return await localDataSource.delete(id);
  }
}
