import '../../../features/module/domain/module_entity.dart';
import '../../../features/module/data/module_constants.dart';

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    super.moduleID,
    required super.title,
    super.tasks = const [],
  });

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
      tasks: entity.tasks,
    );
  }

  ModuleEntity toEntity() => ModuleEntity(
    moduleID: moduleID,
    title: title,
    tasks: tasks,
  );
}
