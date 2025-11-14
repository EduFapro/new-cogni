import '../../../core/constants/enums/progress_status.dart';
import '../../module_instance/domain/module_instance_entity.dart';
import 'module_instance_constants.dart';

class ModuleInstanceModel extends ModuleInstanceEntity {
  const ModuleInstanceModel({
    super.id,
    required super.moduleId,
    required super.status,
    super.module,
  });

  factory ModuleInstanceModel.fromMap(Map<String, dynamic> map) {
    return ModuleInstanceModel(
      id: map[ModuleInstanceFields.id] as int?,
      moduleId: map[ModuleInstanceFields.moduleId] as int,
      status: ModuleStatus.fromValue(map[ModuleInstanceFields.status] as int),
    );
  }

  Map<String, dynamic> toMap() => {
    ModuleInstanceFields.id: id,
    ModuleInstanceFields.moduleId: moduleId,
    ModuleInstanceFields.status: status.numericValue,
  };

  factory ModuleInstanceModel.fromEntity(ModuleInstanceEntity entity) {
    return ModuleInstanceModel(
      id: entity.id,
      moduleId: entity.moduleId,
      status: entity.status,
      module: entity.module,
    );
  }

  ModuleInstanceEntity toEntity() {
    return ModuleInstanceEntity(
      id: id,
      moduleId: moduleId,
      status: status,
      module: module,
    );
  }
}
