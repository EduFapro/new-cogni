import '../../task_prompt/domain/task_prompt_entity.dart';
import 'task_prompt_constants.dart';

class TaskPromptModel extends TaskPromptEntity {
  const TaskPromptModel({
    super.id,
    required super.taskId,
    required super.filePath,
    super.transcription,
  });

  factory TaskPromptModel.fromMap(Map<String, dynamic> map) {
    return TaskPromptModel(
      id: map[TaskPromptFields.id] as int?,
      taskId: map[TaskPromptFields.taskId] as int,
      filePath: map[TaskPromptFields.filePath] as String,
      transcription: map[TaskPromptFields.transcription] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    TaskPromptFields.id: id,
    TaskPromptFields.taskId: taskId,
    TaskPromptFields.filePath: filePath,
    TaskPromptFields.transcription: transcription,
  };

  factory TaskPromptModel.fromEntity(TaskPromptEntity entity) =>
      TaskPromptModel(
        id: entity.id,
        taskId: entity.taskId,
        filePath: entity.filePath,
        transcription: entity.transcription,
      );

  TaskPromptEntity toEntity() => TaskPromptEntity(
    id: id,
    taskId: taskId,
    filePath: filePath,
    transcription: transcription,
  );
}
