import 'task_entity.dart';

abstract class TaskRepository {
  Future<int?> insertTask(TaskEntity task);
  Future<TaskEntity?> getTaskById(int id);
  Future<List<TaskEntity>> getAllTasks();
  Future<List<TaskEntity>> getTasksByModuleId(int moduleId);
  Future<int> updateTask(TaskEntity task);
  Future<int> deleteTask(int id);
}
