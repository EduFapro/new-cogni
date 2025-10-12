import '../../recording_file/domain/recording_file_entity.dart';
import '../../recording_file/data/recording_file_constants.dart';

class RecordingFileModel extends RecordingFileEntity {
  const RecordingFileModel({
    super.id,
    required super.taskInstanceId,
    required super.filePath,
  });

  factory RecordingFileModel.fromMap(Map<String, dynamic> map) {
    return RecordingFileModel(
      id: map[RecordingFileFields.id] as int?,
      taskInstanceId: map[RecordingFileFields.taskInstanceId] as int,
      filePath: map[RecordingFileFields.filePath] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    RecordingFileFields.id: id,
    RecordingFileFields.taskInstanceId: taskInstanceId,
    RecordingFileFields.filePath: filePath,
  };

  factory RecordingFileModel.fromEntity(RecordingFileEntity entity) =>
      RecordingFileModel(
        id: entity.id,
        taskInstanceId: entity.taskInstanceId,
        filePath: entity.filePath,
      );

  RecordingFileEntity toEntity() => RecordingFileEntity(
    id: id,
    taskInstanceId: taskInstanceId,
    filePath: filePath,
  );
}
