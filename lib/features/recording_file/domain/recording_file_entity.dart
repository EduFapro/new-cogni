class RecordingFileEntity {
  final int? id;
  final int taskInstanceId;
  final String filePath;

  const RecordingFileEntity({
    this.id,
    required this.taskInstanceId,
    required this.filePath,
  });

  RecordingFileEntity copyWith({
    int? id,
    int? taskInstanceId,
    String? filePath,
  }) {
    return RecordingFileEntity(
      id: id ?? this.id,
      taskInstanceId: taskInstanceId ?? this.taskInstanceId,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String toString() =>
      'RecordingFileEntity(id: $id, taskInstanceId: $taskInstanceId, filePath: $filePath)';
}
