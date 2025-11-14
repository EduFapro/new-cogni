// data/module_repository_impl.dart

import '../../task/data/task_local_datasource.dart';
import '../domain/module_entity.dart';
import '../domain/module_repository.dart';
import 'module_local_datasource.dart';
import 'module_model.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleLocalDataSource local;
  final TaskLocalDataSource taskLocal;

  ModuleRepositoryImpl({
    required this.local,
    required this.taskLocal,
  });

  @override
  Future<int?> insertModule(ModuleEntity module) {
    return local.insertModule(ModuleModel.fromEntity(module));
  }

  @override
  Future<List<ModuleEntity>> getAllModules() async {
    final modules = await local.getAllModules();
    return modules.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ModuleEntity?> getModuleById(int id) async {
    final module = await local.getModuleById(id);
    if (module == null) return null;
    final tasks = await taskLocal.getTasksByModuleId(id);
    return module.toEntity().copyWith(tasks: tasks);
  }

  @override
  Future<ModuleEntity?> getModuleByTitle(String title) async {
    final module = await local.getModuleByTitle(title);
    if (module == null || module.moduleID == null) return null;
    final tasks = await taskLocal.getTasksByModuleId(module.moduleID!);
    return module.toEntity().copyWith(tasks: tasks);
  }

  @override
  Future<int> updateModule(ModuleEntity module) {
    return local.updateModule(ModuleModel.fromEntity(module));
  }

  @override
  Future<int> deleteModule(int id) {
    return local.deleteModule(id);
  }

  @override
  Future<int> getNumberOfModules() {
    return local.getNumberOfModules();
  }
}
