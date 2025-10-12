library module_seeds;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/logger/app_logger.dart';
import '../../features/module/data/module_constants.dart';
import '../../features/module/data/module_model.dart';
import '../../features/module/domain/module_entity.dart';
part 'modules_seeds_constants.dart';

Future<void> seedModules(Database db) async {
  AppLogger.seed('[MODULES] Seeding modules...');
  final modules = [
    ModuleEntity(moduleID: 1, title: 'Sociodemographic Info'),
    ModuleEntity(moduleID: 2, title: 'Cognitive Functions'),
    ModuleEntity(moduleID: 3, title: 'Functionality'),
    ModuleEntity(moduleID: 4, title: 'Depression Symptoms'),
    ModuleEntity(moduleID: 5, title: 'Tests'),
  ];

  for (final module in modules) {
    final result = await db.query(
      'modules',
      where: '${ModuleFields.id} = ?',
      whereArgs: [module.moduleID],
    );
    if (result.isEmpty) {
      await db.insert('modules', module.toModel().toMap());
      AppLogger.seed('[MODULES] Seeded module: ${module.moduleID} → ${module.title}');
    } else {
      AppLogger.debug('[MODULES] Skipped existing module: ${module.moduleID}');
    }
  }
  AppLogger.seed('[MODULES] Done seeding modules.');
}

extension ModuleEntityMapper on ModuleEntity {
  ModuleModel toModel() => ModuleModel(
    moduleID: moduleID,
    title: title,
  );
}