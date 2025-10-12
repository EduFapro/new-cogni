

import '../../../core/constants/enums/task_mode.dart';

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

  TaskEntity copyWith({
    int? id,
    int? moduleId,
    String? title,
    String? transcript,
    TaskMode? mode,
    int? position,
    String? imagePath,
    int? timeForCompletion,
    bool? mayRepeatPrompt,
    bool? testOnly,
  }) {
    return TaskEntity(
      taskID: id ?? this.taskID,
      moduleID: moduleId ?? this.moduleID,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      taskMode: mode ?? this.taskMode,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      timeForCompletion: timeForCompletion ?? this.timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt ?? this.mayRepeatPrompt,
      testOnly: testOnly ?? this.testOnly,
    );
  }

  @override
  String toString() {
    return 'TaskEntity(id: $taskID, title: $title, mode: $taskMode, moduleId: $moduleID, pos: $position)';
  }
}
