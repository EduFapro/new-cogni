import '../../../core/constants/enums/task_mode.dart';
import '../../task/domain/task_entity.dart';
import '../../task/data/task_constants.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.taskID,
    required super.moduleID,
    required super.title,
    required super.taskMode,
    required super.position,
    super.imageAssetPath = 'no_image',
    super.videoAssetPath,
    super.timeForCompletion = 60,
    super.mayRepeatPrompt = true,
    super.testOnly = false,
    super.transcript,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      taskID: map[TaskFields.id] as int?,
      moduleID: map[TaskFields.moduleId] as int,
      title: map[TaskFields.title] as String,
      transcript: map[TaskFields.transcript] as String?,
      taskMode: TaskMode.fromValue(map[TaskFields.mode] as int),
      position: map[TaskFields.position] as int,
      imageAssetPath: map[TaskFields.imagePath] as String? ?? 'no_image',
      videoAssetPath: map[TaskFields.videoPath] as String?,
      timeForCompletion: map[TaskFields.timeForCompletion] as int? ?? 60,
      mayRepeatPrompt: (map[TaskFields.mayRepeatPrompt] as int) == 1,
      testOnly: (map[TaskFields.testOnly] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    TaskFields.id: taskID,
    TaskFields.moduleId: moduleID,
    TaskFields.title: title,
    TaskFields.transcript: transcript,
    TaskFields.mode: taskMode.numericValue,
    TaskFields.position: position,
    TaskFields.imagePath: imageAssetPath,
    TaskFields.videoPath: videoAssetPath,
    TaskFields.timeForCompletion: timeForCompletion,
    TaskFields.mayRepeatPrompt: mayRepeatPrompt ? 1 : 0,
    TaskFields.testOnly: testOnly ? 1 : 0,
  };

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
    taskID: entity.taskID,
    moduleID: entity.moduleID,
    title: entity.title,
    transcript: entity.transcript,
    taskMode: entity.taskMode,
    position: entity.position,
    imageAssetPath: entity.imageAssetPath,
    videoAssetPath: entity.videoAssetPath,
    timeForCompletion: entity.timeForCompletion,
    mayRepeatPrompt: entity.mayRepeatPrompt,
    testOnly: entity.testOnly,
  );

  TaskEntity toEntity() => TaskEntity(
    taskID: taskID,
    moduleID: moduleID,
    title: title,
    transcript: transcript,
    taskMode: taskMode,
    position: position,
    imageAssetPath: imageAssetPath,
    videoAssetPath: videoAssetPath,
    timeForCompletion: timeForCompletion,
    mayRepeatPrompt: mayRepeatPrompt,
    testOnly: testOnly,
  );
}
