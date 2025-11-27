import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_repository.dart';
import 'task_instance_local_datasource.dart';
import 'task_instance_model.dart';

import '../../task/domain/task_repository.dart';

class TaskInstanceRepositoryImpl implements TaskInstanceRepository {
  final TaskInstanceLocalDataSource localDataSource;
  final TaskRepository taskRepository;

  TaskInstanceRepositoryImpl({
    required this.localDataSource,
    required this.taskRepository,
  });

  @override
  Future<int?> insert(TaskInstanceEntity entity) async {
    final model = TaskInstanceModel.fromEntity(entity);
    return await localDataSource.create(model);
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
    return await localDataSource.markAsCompleted(id, duration: duration);
  }
}
