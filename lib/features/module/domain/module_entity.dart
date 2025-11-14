// domain/module_entity.dart

import '../../task/domain/task_entity.dart';

class ModuleEntity {
  final int? moduleID;
  final String title;
  final List<TaskEntity> tasks;

  const ModuleEntity({
    this.moduleID,
    required this.title,
    this.tasks = const [],
  });

  ModuleEntity copyWith({
    int? moduleID,
    String? title,
    List<TaskEntity>? tasks,
  }) {
    return ModuleEntity(
      moduleID: moduleID ?? this.moduleID,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() => {
    'module_id': moduleID,
    'title': title,
  };

  factory ModuleEntity.fromMap(Map<String, dynamic> map) {
    return ModuleEntity(
      moduleID: map['module_id'] as int?,
      title: map['title'] as String,
    );
  }

  @override
  String toString() => 'ModuleEntity(id: $moduleID, title: $title)';
}
