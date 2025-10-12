import '../../task_prompt/domain/task_prompt_entity.dart';
import 'task_prompt_constants.dart';

class TaskPromptModel extends TaskPromptEntity {
  const TaskPromptModel({
    super.promptID,
    required super.taskID,
    required super.filePath,
    super.transcription,
  });

  factory TaskPromptModel.fromMap(Map<String, dynamic> map) {
    return TaskPromptModel(
      promptID: map[TaskPromptFields.promptID] as int?,
      taskID: map[TaskPromptFields.taskID] as int, //
      filePath: map[TaskPromptFields.filePath] as String,
      transcription: map[TaskPromptFields.transcription] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    TaskPromptFields.promptID: promptID,
    TaskPromptFields.taskID: taskID,
    TaskPromptFields.filePath: filePath,
    TaskPromptFields.transcription: transcription,
  };

  factory TaskPromptModel.fromEntity(TaskPromptEntity entity) =>
      TaskPromptModel(
        promptID: entity.promptID,
        taskID: entity.taskID,
        filePath: entity.filePath,
        transcription: entity.transcription,
      );

  TaskPromptEntity toEntity() => TaskPromptEntity(
    promptID: promptID,
    taskID: taskID,
    filePath: filePath,
    transcription: transcription,
  );
}
