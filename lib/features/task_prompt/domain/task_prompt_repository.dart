import 'task_prompt_entity.dart';

abstract class TaskPromptRepository {
  Future<int?> insert(TaskPromptEntity entity);
  Future<TaskPromptEntity?> getById(int id);
  Future<TaskPromptEntity?> getByTaskId(int taskId);
  Future<List<TaskPromptEntity>> getAll();
  Future<int> update(TaskPromptEntity entity);
  Future<int> delete(int id);
}
