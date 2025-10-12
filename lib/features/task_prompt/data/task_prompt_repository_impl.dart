import '../../task_prompt/domain/task_prompt_entity.dart';
import '../../task_prompt/domain/task_prompt_repository.dart';
import '../../task_prompt/data/task_prompt_local_datasource.dart';
import '../../task_prompt/data/task_prompt_model.dart';

class TaskPromptRepositoryImpl implements TaskPromptRepository {
  final TaskPromptLocalDataSource localDataSource;

  TaskPromptRepositoryImpl({required this.localDataSource});

  @override
  Future<int?> insert(TaskPromptEntity entity) async {
    final model = TaskPromptModel.fromEntity(entity);
    return await localDataSource.insert(model);
  }

  @override
  Future<TaskPromptEntity?> getById(int id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<TaskPromptEntity?> getByTaskId(int taskId) async {
    final model = await localDataSource.getByTaskId(taskId);
    return model?.toEntity();
  }

  @override
  Future<List<TaskPromptEntity>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> update(TaskPromptEntity entity) async {
    final model = TaskPromptModel.fromEntity(entity);
    return await localDataSource.update(model);
  }

  @override
  Future<int> delete(int id) async {
    return await localDataSource.delete(id);
  }
}
