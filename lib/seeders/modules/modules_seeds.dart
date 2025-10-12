library module_seeds;

import '../../core/logger/app_logger.dart';
import '../../features/module/data/module_local_datasource.dart';
import '../../features/module/data/module_model.dart';
import '../../features/module/domain/module_entity.dart';
part 'modules_seeds_constants.dart';

Future<void> seedModules() async {
  final datasource = ModuleLocalDataSource();

  final modules = [
    ModuleEntity(moduleID: 1, title: 'Sociodemographic Info'),
    ModuleEntity(moduleID: 2, title: 'Cognitive Functions'),
    ModuleEntity(moduleID: 3, title: 'Functionality'),
    ModuleEntity(moduleID: 4, title: 'Depression Symptoms'),
    ModuleEntity(moduleID: 5, title: 'Tests'),
  ];

  for (final module in modules) {
    final exists = await datasource.exists(module.moduleID.toString());
    if (!exists) {
      await datasource.insertModule(module.toModel());
      AppLogger.seed('Seeded module: ${module.moduleID} → ${module.title}');
    } else {
      AppLogger.debug('Skipped existing module: ${module.moduleID}');
    }
  }
}

extension ModuleEntityMapper on ModuleEntity {
  ModuleModel toModel() => ModuleModel(
    moduleID: moduleID,
    title: title,
  );
}
