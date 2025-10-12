import '../../task/domain/task_entity.dart';
import '../../../core/constants/enums/progress_status.dart';

class TaskInstanceEntity {
  final int? id;
  final int taskId;
  final int moduleInstanceId;
  final TaskStatus status;
  final String? completingTime;
  final TaskEntity? task;

  const TaskInstanceEntity({
    this.id,
    required this.taskId,
    required this.moduleInstanceId,
    this.status = TaskStatus.pending,
    this.completingTime,
    this.task,
  });

  TaskInstanceEntity copyWith({
    int? id,
    int? taskId,
    int? moduleInstanceId,
    TaskStatus? status,
    String? completingTime,
    TaskEntity? task,
  }) {
    return TaskInstanceEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      moduleInstanceId: moduleInstanceId ?? this.moduleInstanceId,
      status: status ?? this.status,
      completingTime: completingTime ?? this.completingTime,
      task: task ?? this.task,
    );
  }

  @override
  String toString() =>
      'TaskInstanceEntity(id: $id, taskId: $taskId, moduleInstanceId: $moduleInstanceId, status: $status, completingTime: $completingTime)';
}
