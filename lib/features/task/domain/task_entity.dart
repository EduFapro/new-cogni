import '../../../core/constants/enums/task_mode.dart';
import '../data/task_constants.dart';

class TaskEntity {
  final int? taskID;
  final int moduleID;
  final String title;
  final String? transcript;
  final TaskMode taskMode;
  final int position;
  final String imageAssetPath;
  final String? videoAssetPath;
  final int timeForCompletion;
  final bool mayRepeatPrompt;
  final bool testOnly;

  const TaskEntity({
    this.taskID,
    required this.moduleID,
    required this.title,
    required this.taskMode,
    required this.position,
    this.transcript,
    this.imageAssetPath = 'no_image',
    this.videoAssetPath,
    this.timeForCompletion = 60,
    this.mayRepeatPrompt = true,
    this.testOnly = false,
  });

  Map<String, dynamic> toMap() => {
    TaskFields.id: taskID,
    TaskFields.moduleId: moduleID,
    TaskFields.title: title,
    TaskFields.transcript: transcript,
    TaskFields.mode: taskMode.index,
    TaskFields.position: position,
    TaskFields.imagePath: imageAssetPath,
    TaskFields.videoPath: videoAssetPath,
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
    imageAssetPath: map[TaskFields.imagePath] as String,
    videoAssetPath: map[TaskFields.videoPath] as String?,
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
    String? imageAssetPath,
    String? videoAssetPath,
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
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      videoAssetPath: videoAssetPath ?? this.videoAssetPath,
      timeForCompletion: timeForCompletion ?? this.timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt ?? this.mayRepeatPrompt,
      testOnly: testOnly ?? this.testOnly,
    );
  }

  @override
  String toString() =>
      'TaskEntity(id: $taskID, title: $title, mode: $taskMode, moduleId: $moduleID, pos: $position)';
}
