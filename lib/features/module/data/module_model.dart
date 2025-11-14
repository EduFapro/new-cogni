// data/module_model.dart

import '../domain/module_entity.dart';
import 'module_constants.dart';

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    int? moduleID,
    required String title,
  }) : super(moduleID: moduleID, title: title);

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      moduleID: map[ModuleFields.id] as int?,
      title: map[ModuleFields.title] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    ModuleFields.id: moduleID,
    ModuleFields.title: title,
  };

  factory ModuleModel.fromEntity(ModuleEntity entity) {
    return ModuleModel(
      moduleID: entity.moduleID,
      title: entity.title,
    );
  }

  ModuleEntity toEntity() => ModuleEntity(
    moduleID: moduleID,
    title: title,
  );
}
