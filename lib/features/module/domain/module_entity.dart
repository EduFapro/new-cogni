import '../../task/domain/task_entity.dart';

class ModuleEntity {
  final int? id;
  final String title;
  final List<TaskEntity> tasks;

  const ModuleEntity({
    this.id,
    required this.title,
    this.tasks = const [],
  });

  ModuleEntity copyWith({
    int? id,
    String? title,
    List<TaskEntity>? tasks,
  }) {
    return ModuleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  String toString() => 'ModuleEntity(id: $id, title: $title, tasks: $tasks)';
}
