library module_seeds;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/database_constants.dart';
import '../../core/logger/app_logger.dart';

import '../../features/module/data/module_constants.dart';
import '../../features/module/data/module_model.dart';
import '../../features/module/domain/module_entity.dart';

part 'modules_seeds_constants.dart';

final ModuleEntity sociodemographicInfoModule = ModuleEntity(
  moduleID: sociodemographicInfoId,
  title: sociodemographicInfo,
);

final ModuleEntity cognitiveFunctionsModule = ModuleEntity(
  moduleID: cognitiveFunctionsId,
  title: cognitiveFunctions,
);

final ModuleEntity functionalityModule = ModuleEntity(
  moduleID: functionalityId,
  title: functionality,
);

final ModuleEntity depressionSymptomsModule = ModuleEntity(
  moduleID: depressionSymptomsId,
  title: depressionSymptoms,
);

/// Optional module for internal tests/validation
final ModuleEntity testsModule = ModuleEntity(
  moduleID: testsModuleId,
  title: testsModuleTitle,
);

final List<ModuleEntity> modulesList = [
  sociodemographicInfoModule,
  cognitiveFunctionsModule,
  functionalityModule,
  depressionSymptomsModule,
  testsModule,
];

/// --- mapping ---

extension ModuleEntityMapper on ModuleEntity {
  ModuleModel toModel() {
    return ModuleModel(
      moduleID: moduleID,
      title: title,
      // adapt if ModuleModel has more fields, e.g.:
      // testOnly: moduleID == testsModuleId,
    );
  }
}

/// --- seeder ---

Future<void> seedModules(Database db) async {
  AppLogger.seed('[MODULES] Seeding modules...');

  for (final module in modulesList) {
    final existing = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [module.moduleID],
    );

    if (existing.isEmpty) {
      await db.insert(Tables.modules, module.toModel().toMap());
      AppLogger.seed(
        '[MODULES] Seeded module: ${module.title} (id=${module.moduleID})',
      );
    } else {
      AppLogger.debug(
        '[MODULES] Skipped existing module: ${module.title} (id=${module.moduleID})',
      );
    }
  }

  AppLogger.seed('[MODULES] Done seeding modules.');
}

void printModules() {
  for (var i = 0; i < modulesList.length; i++) {
    AppLogger.seed('Module ${modulesList[i].moduleID}: ${modulesList[i].title}');
  }
}
