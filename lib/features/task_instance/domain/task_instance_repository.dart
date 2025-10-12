import 'task_instance_entity.dart';

abstract class TaskInstanceRepository {
  Future<int?> insert(TaskInstanceEntity entity);
  Future<TaskInstanceEntity?> getById(int id);
  Future<List<TaskInstanceEntity>> getAll();
  Future<int> update(TaskInstanceEntity entity);
  Future<int> delete(int id);
  Future<List<TaskInstanceEntity>> getByModuleInstance(int moduleInstanceId);
}
