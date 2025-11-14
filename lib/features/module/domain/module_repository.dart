// domain/module_repository.dart

import 'module_entity.dart';

abstract class ModuleRepository {
  Future<int?> insertModule(ModuleEntity module);
  Future<List<ModuleEntity>> getAllModules();
  Future<ModuleEntity?> getModuleById(int id);
  Future<ModuleEntity?> getModuleByTitle(String title);
  Future<int> updateModule(ModuleEntity module);
  Future<int> deleteModule(int id);
  Future<int> getNumberOfModules();
}
