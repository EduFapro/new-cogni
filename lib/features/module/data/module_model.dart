import '../../../features/module/domain/module_entity.dart';
import '../../../features/module/data/module_constants.dart';

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    super.id,
    required super.title,
    super.tasks = const [],
  });

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      id: map[ModuleFields.id] as int?,
      title: map[ModuleFields.title] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    ModuleFields.id: id,
    ModuleFields.title: title,
  };

  factory ModuleModel.fromEntity(ModuleEntity entity) {
    return ModuleModel(
      id: entity.id,
      title: entity.title,
      tasks: entity.tasks,
    );
  }

  ModuleEntity toEntity() => ModuleEntity(
    id: id,
    title: title,
    tasks: tasks,
  );
}
