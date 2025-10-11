

import '../../../core/constants/enums/task_mode.dart';

class TaskEntity {
  final int? id;
  final int moduleId;
  final String title;
  final String? transcript;
  final TaskMode mode;
  final int position;
  final String imagePath;
  final int timeForCompletion;
  final bool mayRepeatPrompt;
  final bool testOnly;

  const TaskEntity({
    this.id,
    required this.moduleId,
    required this.title,
    required this.mode,
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
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      mode: mode ?? this.mode,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      timeForCompletion: timeForCompletion ?? this.timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt ?? this.mayRepeatPrompt,
      testOnly: testOnly ?? this.testOnly,
    );
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, mode: $mode, moduleId: $moduleId, pos: $position)';
  }
}
