class TaskPromptEntity {
  final int? promptID;
  final int taskID;
  final String filePath;
  final String? transcription;

  const TaskPromptEntity({
    this.promptID,
    required this.taskID,
    required this.filePath,
    this.transcription,
  });

  TaskPromptEntity copyWith({
    int? promptID,
    int? taskId,
    String? filePath,
    String? transcription,
  }) {
    return TaskPromptEntity(
      promptID: promptID ?? this.promptID,
      taskID: taskId ?? this.taskID,
      filePath: filePath ?? this.filePath,
      transcription: transcription ?? this.transcription,
    );
  }

  @override
  String toString() =>
      'TaskPromptEntity(id: $promptID, taskId: $taskID, filePath: $filePath, transcription: $transcription)';
}
