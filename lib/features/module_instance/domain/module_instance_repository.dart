import '../../../core/constants/enums/progress_status.dart';
import 'module_instance_entity.dart';

abstract class ModuleInstanceRepository {
  Future<ModuleInstanceEntity?> createModuleInstance(ModuleInstanceEntity instance);
  Future<ModuleInstanceEntity?> getModuleInstanceById(int id);
  Future<List<ModuleInstanceEntity>> getAllModuleInstances();
  Future<List<ModuleInstanceEntity>> getModuleInstancesByEvaluationId(int evaluationId);
  Future<int> updateModuleInstance(ModuleInstanceEntity instance);
  Future<int> deleteModuleInstance(int id);
  Future<int> getCount();
  Future<int> setModuleInstanceStatus(int instanceId, ModuleStatus status);
}
