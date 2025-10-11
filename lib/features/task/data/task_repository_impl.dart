import '../domain/task_repository.dart';
import '../domain/task_entity.dart';
import 'task_local_datasource.dart';
import 'task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<int?> insertTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    return await localDataSource.insertTask(model);
  }

  @override
  Future<TaskEntity?> getTaskById(int id) async {
    final model = await localDataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = await localDataSource.getAllTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByModuleId(int moduleId) async {
    final models = await localDataSource.getTasksByModuleId(moduleId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    return await localDataSource.updateTask(model);
  }

  @override
  Future<int> deleteTask(int id) async {
    return await localDataSource.deleteTask(id);
  }
}
