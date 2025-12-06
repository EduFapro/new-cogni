import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_repository.dart';
import 'task_instance_local_datasource.dart';
import 'task_instance_model.dart';
import 'task_instance_remote_data_source.dart';

import '../../task/domain/task_repository.dart';
import '../../../core/logger/app_logger.dart';
import '../../../shared/env/env_helper.dart';
import '../../../core/environment.dart';

class TaskInstanceRepositoryImpl implements TaskInstanceRepository {
  final TaskInstanceLocalDataSource localDataSource;
  final TaskInstanceRemoteDataSource? remoteDataSource;
  final TaskRepository taskRepository;

  TaskInstanceRepositoryImpl({
    required this.localDataSource,
    required this.taskRepository,
    this.remoteDataSource,
  });

  @override
  Future<int?> insert(TaskInstanceEntity entity) async {
    // 1. Local Insert
    final model = TaskInstanceModel.fromEntity(entity);
    final id = await localDataSource.create(model);

    // 2. Remote Sync (Fire-and-forget)
    if (remoteDataSource != null && id != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        _syncToBackend(() async {
          final entityWithId = entity.copyWith(id: id);
          final backendId = await remoteDataSource!.createTaskInstance(
            entityWithId,
          );
          if (backendId != null) {
            AppLogger.info(
              'TaskInstance synced to backend with ID: $backendId',
            );
          }
        });
      } else {
        AppLogger.info('📴 Offline mode: Skipping TaskInstance sync.');
      }
    }

    return id;
  }

  @override
  Future<TaskInstanceEntity?> getById(int id) async {
    final model = await localDataSource.getTaskInstance(id);
    return model?.toEntity();
  }

  @override
  Future<List<TaskInstanceEntity>> getAll() async {
    final models = await localDataSource.getAllTaskInstances();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> update(TaskInstanceEntity entity) async {
    final model = TaskInstanceModel.fromEntity(entity);
    return await localDataSource.updateTaskInstance(model);
  }

  @override
  Future<int> delete(int id) async {
    return await localDataSource.deleteTaskInstance(id);
  }

  @override
  Future<List<TaskInstanceEntity>> getByModuleInstance(
    int moduleInstanceId,
  ) async {
    final models = await localDataSource.getTaskInstancesForModuleInstance(
      moduleInstanceId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TaskInstanceEntity?> getInstanceWithTask(int id) async {
    final instanceModel = await localDataSource.getTaskInstance(id);
    if (instanceModel == null) return null;

    final task = await taskRepository.getTaskById(instanceModel.taskId);
    return instanceModel.toEntity().copyWith(task: task);
  }

  @override
  Future<void> markAsCompleted(int id, {String? duration}) async {
    // 1. Local Update
    await localDataSource.markAsCompleted(id, duration: duration);

    // 2. Remote Sync (Fire-and-forget)
    if (remoteDataSource != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        _syncToBackend(() async {
          final success = await remoteDataSource!.markAsCompleted(id, duration);
          if (success) {
            AppLogger.info('TaskInstance $id marked as completed on backend');
          }
        });
      } else {
        AppLogger.info(
          '📴 Offline mode: Skipping TaskInstance completion sync.',
        );
      }
    }
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
