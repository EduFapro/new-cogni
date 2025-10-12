import '../../../core/constants/enums/progress_status.dart';
import '../domain/module_instance_repository.dart';
import '../domain/module_instance_entity.dart';
import 'module_instance_model.dart';
import 'module_instance_local_datasource.dart';

class ModuleInstanceRepositoryImpl implements ModuleInstanceRepository {
  final ModuleInstanceLocalDataSource localDataSource;

  ModuleInstanceRepositoryImpl({required this.localDataSource});

  @override
  Future<ModuleInstanceEntity?> createModuleInstance(
      ModuleInstanceEntity instance) async {
    final model = ModuleInstanceModel.fromEntity(instance);
    final id = await localDataSource.insertModuleInstance(model);
    if (id == null) return null;
    final created = await localDataSource.getModuleInstanceById(id);
    return created?.toEntity();
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
      int evaluationId) async {
    final models =
    await localDataSource.getModuleInstancesByEvaluationId(evaluationId);
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
  Future<int> setModuleInstanceStatus(int instanceId, ModuleStatus status) async {
    return await localDataSource.setStatus(instanceId, status);
  }
}
