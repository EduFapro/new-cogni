import '../../../core/constants/enums/task_mode.dart';
import '../../../core/constants/database_constants.dart';
import '../data/task_constants.dart';

class TaskEntity {
  final int? taskID;
  final int moduleID;
  final String title;
  final String? transcript;
  final TaskMode taskMode;
  final int position;
  final String imagePath;
  final int timeForCompletion;
  final bool mayRepeatPrompt;
  final bool testOnly;

  const TaskEntity({
    this.taskID,
    required this.moduleID,
    required this.title,
    required this.taskMode,
    required this.position,
    this.imagePath = 'no_image',
    this.timeForCompletion = 60,
    this.mayRepeatPrompt = true,
    this.testOnly = false,
    this.transcript,
  });

  Map<String, dynamic> toMap() => {
    TaskFields.id: taskID,
    TaskFields.moduleId: moduleID,
    TaskFields.title: title,
    TaskFields.transcript: transcript,
    TaskFields.mode: taskMode.index,
    TaskFields.position: position,
    TaskFields.imagePath: imagePath,
    TaskFields.timeForCompletion: timeForCompletion,
    TaskFields.mayRepeatPrompt: mayRepeatPrompt ? 1 : 0,
    TaskFields.testOnly: testOnly ? 1 : 0,
  };

  factory TaskEntity.fromMap(Map<String, dynamic> map) => TaskEntity(
    taskID: map[TaskFields.id] as int?,
    moduleID: map[TaskFields.moduleId] as int,
    title: map[TaskFields.title] as String,
    transcript: map[TaskFields.transcript] as String?,
    taskMode: TaskMode.values[map[TaskFields.mode] as int],
    position: map[TaskFields.position] as int,
    imagePath: map[TaskFields.imagePath] as String,
    timeForCompletion: map[TaskFields.timeForCompletion] as int,
    mayRepeatPrompt: (map[TaskFields.mayRepeatPrompt] as int) == 1,
    testOnly: (map[TaskFields.testOnly] as int) == 1,
  );

  TaskEntity copyWith({
    int? taskID,
    int? moduleID,
    String? title,
    String? transcript,
    TaskMode? taskMode,
    int? position,
    String? imagePath,
    int? timeForCompletion,
    bool? mayRepeatPrompt,
    bool? testOnly,
  }) {
    return TaskEntity(
      taskID: taskID ?? this.taskID,
      moduleID: moduleID ?? this.moduleID,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      taskMode: taskMode ?? this.taskMode,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      timeForCompletion: timeForCompletion ?? this.timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt ?? this.mayRepeatPrompt,
      testOnly: testOnly ?? this.testOnly,
    );
  }

  @override
  String toString() =>
      'TaskEntity(id: $taskID, title: $title, mode: $taskMode, moduleId: $moduleID, pos: $position)';
}
