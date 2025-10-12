import '../../../core/constants/database_constants.dart';
import '../../task_instance/data/task_instance_constants.dart';

class RecordingFileFields {
  static const id = 'recording_id';
  static const taskInstanceId = TaskInstanceFields.id;
  static const filePath = 'file_path';

  static const values = [id, taskInstanceId, filePath];
}

final scriptCreateTableRecordings = '''
CREATE TABLE ${Tables.recordings} (
  ${RecordingFileFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${RecordingFileFields.taskInstanceId} INTEGER UNIQUE NOT NULL,
  ${RecordingFileFields.filePath} TEXT NOT NULL,
  FOREIGN KEY (${RecordingFileFields.taskInstanceId}) 
    REFERENCES ${Tables.taskInstances}(${TaskInstanceFields.id})
)
''';
