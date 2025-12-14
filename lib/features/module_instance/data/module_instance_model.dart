import '../../../core/constants/enums/progress_status.dart';
import '../../module/domain/module_entity.dart';
import '../../module_instance/domain/module_instance_entity.dart';
import 'module_instance_constants.dart';

class ModuleInstanceModel extends ModuleInstanceEntity {
  const ModuleInstanceModel({
    super.id,
    required super.moduleId,
    required super.evaluationId,
    required super.status,
    super.module,
    super.completionDate,
  });

  factory ModuleInstanceModel.fromMap(Map<String, dynamic> map) {
    return ModuleInstanceModel(
      id: map[ModuleInstanceFields.id] as int?,
      moduleId: map[ModuleInstanceFields.moduleId] as int,
      evaluationId: map[ModuleInstanceFields.evaluationId] as int,
      status: ModuleStatus.fromValue(map[ModuleInstanceFields.status] as int),
      completionDate: map['completionDate'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    ModuleInstanceFields.id: id,
    ModuleInstanceFields.moduleId: moduleId,
    ModuleInstanceFields.evaluationId: evaluationId,
    ModuleInstanceFields.status: status.numericValue,
    'completionDate': completionDate,
  };

  factory ModuleInstanceModel.fromEntity(ModuleInstanceEntity entity) {
    return ModuleInstanceModel(
      id: entity.id,
      moduleId: entity.moduleId,
      evaluationId: entity.evaluationId,
      status: entity.status,
      module: entity.module,
      completionDate: entity.completionDate,
    );
  }

  ModuleInstanceEntity toEntity() {
    return ModuleInstanceEntity(
      id: id,
      moduleId: moduleId,
      evaluationId: evaluationId,
      status: status,
      module: module,
      completionDate: completionDate,
    );
  }

  ModuleInstanceModel copyWith({
    int? id,
    int? moduleId,
    int? evaluationId,
    ModuleStatus? status,
    ModuleEntity? module,
    String? completionDate,
  }) {
    return ModuleInstanceModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      evaluationId: evaluationId ?? this.evaluationId,
      status: status ?? this.status,
      module: module ?? this.module,
      completionDate: completionDate ?? this.completionDate,
    );
  }
}
