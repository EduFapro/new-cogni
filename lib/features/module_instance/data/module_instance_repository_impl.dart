import '../../../core/constants/enums/progress_status.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/module_instance_repository.dart';
import '../domain/module_instance_entity.dart';
import 'module_instance_model.dart';
import 'module_instance_local_datasource.dart';
import 'module_instance_remote_data_source.dart';

import '../../../shared/env/env_helper.dart';
import '../../../core/environment.dart';

class ModuleInstanceRepositoryImpl implements ModuleInstanceRepository {
  final ModuleInstanceLocalDataSource localDataSource;
  final ModuleInstanceRemoteDataSource? remoteDataSource;

  ModuleInstanceRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<ModuleInstanceEntity?> createModuleInstance(
    ModuleInstanceEntity instance,
  ) async {
    // 1. Local Insert
    final model = ModuleInstanceModel.fromEntity(instance);
    final id = await localDataSource.insertModuleInstance(model);
    if (id == null) return null;

    final created = await localDataSource.getModuleInstanceById(id);
    final createdEntity = created?.toEntity();

    // 2. Remote Sync (Fire-and-forget)
    if (remoteDataSource != null && createdEntity != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        _syncToBackend(() async {
          final backendId = await remoteDataSource!.createModuleInstance(
            createdEntity,
          );
          if (backendId != null) {
            AppLogger.info(
              'ModuleInstance synced to backend with ID: $backendId',
            );
          }
        });
      } else {
        AppLogger.info('📴 Offline mode: Skipping ModuleInstance sync.');
      }
    }

    return createdEntity;
  }

  @override
  Future<ModuleInstanceEntity?> getModuleInstanceById(int id) async {
    final model = await localDataSource.getModuleInstanceById(id);
    return model?.toEntity();
  }

  @override
  Future<List<ModuleInstanceEntity>> getAllModuleInstances() async {
    final models = await localDataSource.getAllModuleInstances();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ModuleInstanceEntity>> getModuleInstancesByEvaluationId(
    int evaluationId,
  ) async {
    final models = await localDataSource.getModuleInstancesByEvaluationId(
      evaluationId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> updateModuleInstance(ModuleInstanceEntity instance) async {
    final model = ModuleInstanceModel.fromEntity(instance);
    return await localDataSource.updateModuleInstance(model);
  }

  @override
  Future<int> deleteModuleInstance(int id) async {
    return await localDataSource.deleteModuleInstance(id);
  }

  @override
  Future<int> getCount() async {
    return await localDataSource.getCount();
  }

  @override
  Future<int> setModuleInstanceStatus(
    int instanceId,
    ModuleStatus status,
  ) async {
    // 1. Local Update
    final result = await localDataSource.setStatus(instanceId, status);

    // 2. Remote Sync (Fire-and-forget)
    if (remoteDataSource != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        _syncToBackend(() async {
          final success = await remoteDataSource!.updateModuleInstanceStatus(
            instanceId,
            status.numericValue,
          );
          if (success) {
            AppLogger.info(
              'ModuleInstance $instanceId status updated on backend',
            );
          }
        });
      } else {
        AppLogger.info('📴 Offline mode: Skipping ModuleInstance status sync.');
      }
    }

    return result;
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
