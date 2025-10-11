import '../../../core/constants/enums/task_mode.dart';
import '../../task/domain/task_entity.dart';
import '../../task/data/task_constants.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    required super.moduleId,
    required super.title,
    required super.mode,
    required super.position,
    super.imagePath = 'no_image',
    super.timeForCompletion = 60,
    super.mayRepeatPrompt = true,
    super.testOnly = false,
    super.transcript,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map[TaskFields.id] as int?,
      moduleId: map[TaskFields.moduleId] as int,
      title: map[TaskFields.title] as String,
      transcript: map[TaskFields.transcript] as String?,
      mode: TaskMode.fromValue(map[TaskFields.mode] as int),
      position: map[TaskFields.position] as int,
      imagePath: map[TaskFields.imagePath] as String? ?? 'no_image',
      timeForCompletion: map[TaskFields.timeForCompletion] as int? ?? 60,
      mayRepeatPrompt: (map[TaskFields.mayRepeatPrompt] as int) == 1,
      testOnly: (map[TaskFields.testOnly] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    TaskFields.id: id,
    TaskFields.moduleId: moduleId,
    TaskFields.title: title,
    TaskFields.transcript: transcript,
    TaskFields.mode: mode.numericValue,
    TaskFields.position: position,
    TaskFields.imagePath: imagePath,
    TaskFields.timeForCompletion: timeForCompletion,
    TaskFields.mayRepeatPrompt: mayRepeatPrompt ? 1 : 0,
    TaskFields.testOnly: testOnly ? 1 : 0,
  };

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
    id: entity.id,
    moduleId: entity.moduleId,
    title: entity.title,
    transcript: entity.transcript,
    mode: entity.mode,
    position: entity.position,
    imagePath: entity.imagePath,
    timeForCompletion: entity.timeForCompletion,
    mayRepeatPrompt: entity.mayRepeatPrompt,
    testOnly: entity.testOnly,
  );

  TaskEntity toEntity() => TaskEntity(
    id: id,
    moduleId: moduleId,
    title: title,
    transcript: transcript,
    mode: mode,
    position: position,
    imagePath: imagePath,
    timeForCompletion: timeForCompletion,
    mayRepeatPrompt: mayRepeatPrompt,
    testOnly: testOnly,
  );
}
