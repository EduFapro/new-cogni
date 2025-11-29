import '../../recording_file/domain/recording_file_entity.dart';
import '../../recording_file/domain/recording_file_repository.dart';
import '../../recording_file/data/recording_file_model.dart';
import '../../recording_file/data/recording_file_local_datasource.dart';
import '../../recording_file/data/recording_file_remote_data_source.dart';
import '../../../core/logger/app_logger.dart';

class RecordingFileRepositoryImpl implements RecordingFileRepository {
  final RecordingFileLocalDataSource localDataSource;
  final RecordingFileRemoteDataSource? remoteDataSource;

  RecordingFileRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<int?> insert(RecordingFileEntity entity) async {
    // 1. Local Insert
    final model = RecordingFileModel.fromEntity(entity);
    final id = await localDataSource.insert(model);

    // 2. Remote Sync (Fire-and-forget)
    if (remoteDataSource != null && id != null) {
      _syncToBackend(() async {
        final entityWithId = entity.copyWith(id: id);
        // Note: This only sends metadata, not the file itself yet
        final backendId = await remoteDataSource!.createRecordingFile(
          entityWithId,
        );
        if (backendId != null) {
          AppLogger.info(
            'RecordingFile metadata synced to backend with ID: $backendId',
          );
          // TODO: Upload actual file content if needed
        }
      });
    }

    return id;
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

  // Helper method for fire-and-forget backend sync
  void _syncToBackend(Future<void> Function() syncOperation) {
    syncOperation().catchError((error, stackTrace) {
      AppLogger.error(
        'Backend sync failed (continuing locally)',
        error,
        stackTrace,
      );
    });
  }
}
