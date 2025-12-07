import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/data/task_instance_constants.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../core/constants/enums/task_mode.dart';
import '../../task/domain/task_entity.dart';

class TaskInstanceModel extends TaskInstanceEntity {
  const TaskInstanceModel({
    super.id,
    required super.taskId,
    required super.moduleInstanceId,
    required super.status,
    super.executionDuration,
    super.task,
  });

  factory TaskInstanceModel.fromMap(Map<String, dynamic> map) {
    final model = TaskInstanceModel(
      id: map[TaskInstanceFields.id] as int?,
      taskId: map[TaskInstanceFields.taskId] as int,
      moduleInstanceId: map[TaskInstanceFields.moduleInstanceId] as int,
      status: TaskStatus.fromValue(map[TaskInstanceFields.status] as int),
      executionDuration: map[TaskInstanceFields.executionDuration] as String?,
    );

    // If task_title is present (from JOIN), populate the task entity
    if (map.containsKey('task_title')) {
      return TaskInstanceModel.fromEntity(
        model.copyWith(
          task: TaskEntity(
            taskID: model.taskId,
            moduleID: 0, // Dummy
            title: map['task_title'] as String,
            taskMode: TaskMode.play, // Dummy
            position: 0, // Dummy
          ),
        ),
      );
    }

    return model;
  }

  Map<String, dynamic> toMap() => {
    TaskInstanceFields.id: id,
    TaskInstanceFields.taskId: taskId,
    TaskInstanceFields.moduleInstanceId: moduleInstanceId,
    TaskInstanceFields.status: status.numericValue,
    TaskInstanceFields.executionDuration: executionDuration,
  };

  factory TaskInstanceModel.fromEntity(TaskInstanceEntity entity) {
    return TaskInstanceModel(
      id: entity.id,
      taskId: entity.taskId,
      moduleInstanceId: entity.moduleInstanceId,
      status: entity.status,
      executionDuration: entity.executionDuration,
      task: entity.task,
    );
  }

  TaskInstanceEntity toEntity() {
    return TaskInstanceEntity(
      id: id,
      taskId: taskId,
      moduleInstanceId: moduleInstanceId,
      status: status,
      executionDuration: executionDuration,
      task: task,
    );
  }
}
