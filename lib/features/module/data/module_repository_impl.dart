import '../../task/data/task_local_datasource.dart';
import '../domain/module_entity.dart';
import '../domain/module_repository.dart';
import 'module_local_datasource.dart';
import 'module_model.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleLocalDataSource localDataSource;
  final TaskLocalDataSource taskLocalDataSource;

  ModuleRepositoryImpl({
    required this.localDataSource,
    required this.taskLocalDataSource,
  });

  @override
  Future<int?> insertModule(ModuleEntity module) async {
    final model = ModuleModel.fromEntity(module);
    return await localDataSource.insertModule(model);
  }

  @override
  Future<List<ModuleEntity>> getAllModules() async {
    final modules = await localDataSource.getAllModules();
    return modules.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ModuleEntity?> getModuleById(int id) async {
    final module = await localDataSource.getModuleById(id);
    if (module == null) return null;

    final tasks = await taskLocalDataSource.getTasksByModuleId(id);
    return module.toEntity().copyWith(tasks: tasks);
  }

  @override
  Future<ModuleEntity?> getModuleByTitle(String title) async {
    final module = await localDataSource.getModuleByTitle(title);
    if (module == null) return null;

    final tasks = await taskLocalDataSource.getTasksByModuleId(module.id!);
    return module.toEntity().copyWith(tasks: tasks);
  }


  @override
  Future<int> updateModule(ModuleEntity module) async {
    final model = ModuleModel.fromEntity(module);
    return await localDataSource.updateModule(model);
  }

  @override
  Future<int> deleteModule(int id) async {
    return await localDataSource.deleteModule(id);
  }

  @override
  Future<int> getNumberOfModules() async {
    return await localDataSource.getNumberOfModules();
  }
}
