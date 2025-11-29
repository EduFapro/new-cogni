import '../../../core/constants/enums/progress_status.dart';
import '../../module/domain/module_entity.dart';

class ModuleInstanceEntity {
  final int? id;
  final int moduleId;
  final int evaluationId;
  final ModuleStatus status;
  final ModuleEntity? module;

  const ModuleInstanceEntity({
    this.id,
    required this.moduleId,
    required this.evaluationId,
    this.status = ModuleStatus.pending,
    this.module,
  });

  ModuleInstanceEntity copyWith({
    int? id,
    int? moduleId,
    int? evaluationId,
    ModuleStatus? status,
    ModuleEntity? module,
  }) {
    return ModuleInstanceEntity(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      evaluationId: evaluationId ?? this.evaluationId,
      status: status ?? this.status,
      module: module ?? this.module,
    );
  }

  @override
  String toString() =>
      'ModuleInstanceEntity(id: $id, moduleId: $moduleId, evaluationId: $evaluationId, status: $status)';

  // For sending to backend API
  Map<String, dynamic> toJsonForApi() => {
    if (id != null) 'id': id,
    'moduleId': moduleId,
    'evaluationId': evaluationId,
    'status': status.numericValue,
  };

  // For receiving from backend API
  factory ModuleInstanceEntity.fromJson(Map<String, dynamic> json) {
    return ModuleInstanceEntity(
      id: json['id'] as int?,
      moduleId: json['moduleId'] as int,
      evaluationId: json['evaluationId'] as int,
      status: ModuleStatus.fromValue(json['status'] as int),
    );
  }
}
