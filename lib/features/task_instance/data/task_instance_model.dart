import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/data/task_instance_constants.dart';
import '../../../core/constants/enums/progress_status.dart';

class TaskInstanceModel extends TaskInstanceEntity {
  const TaskInstanceModel({
    super.id,
    required super.taskId,
    required super.moduleInstanceId,
    required super.status,
    super.completingTime,
    super.task,
  });

  factory TaskInstanceModel.fromMap(Map<String, dynamic> map) {
    return TaskInstanceModel(
      id: map[TaskInstanceFields.id] as int?,
      taskId: map[TaskInstanceFields.taskId] as int,
      moduleInstanceId: map[TaskInstanceFields.moduleInstanceId] as int,
      status: TaskStatus.fromValue(map[TaskInstanceFields.status] as int),
      completingTime: map[TaskInstanceFields.completingTime] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    TaskInstanceFields.id: id,
    TaskInstanceFields.taskId: taskId,
    TaskInstanceFields.moduleInstanceId: moduleInstanceId,
    TaskInstanceFields.status: status.numericValue,
    TaskInstanceFields.completingTime: completingTime,
  };

  factory TaskInstanceModel.fromEntity(TaskInstanceEntity entity) {
    return TaskInstanceModel(
      id: entity.id,
      taskId: entity.taskId,
      moduleInstanceId: entity.moduleInstanceId,
      status: entity.status,
      completingTime: entity.completingTime,
      task: entity.task,
    );
  }

  TaskInstanceEntity toEntity() {
    return TaskInstanceEntity(
      id: id,
      taskId: taskId,
      moduleInstanceId: moduleInstanceId,
      status: status,
      completingTime: completingTime,
      task: task,
    );
  }
}
