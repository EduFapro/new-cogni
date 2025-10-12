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
    int? id,
    String? title,
    List<TaskEntity>? tasks,
  }) {
    return ModuleEntity(
      moduleID: id ?? this.moduleID,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  String toString() => 'ModuleEntity(id: $moduleID, title: $title, tasks: $tasks)';
}
