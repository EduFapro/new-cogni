class TaskPromptEntity {
  final int? id;
  final int taskId;
  final String filePath;
  final String? transcription;

  const TaskPromptEntity({
    this.id,
    required this.taskId,
    required this.filePath,
    this.transcription,
  });

  TaskPromptEntity copyWith({
    int? id,
    int? taskId,
    String? filePath,
    String? transcription,
  }) {
    return TaskPromptEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      filePath: filePath ?? this.filePath,
      transcription: transcription ?? this.transcription,
    );
  }

  @override
  String toString() =>
      'TaskPromptEntity(id: $id, taskId: $taskId, filePath: $filePath, transcription: $transcription)';
}
