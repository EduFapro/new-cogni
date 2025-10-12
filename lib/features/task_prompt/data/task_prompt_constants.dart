import '../../../core/constants/database_constants.dart';
import '../../task/data/task_constants.dart';

class TaskPromptFields {
  static const id = 'prompt_id';
  static const taskId = TaskFields.id;
  static const filePath = 'file_path';
  static const transcription = 'transcription';

  static const values = [id, taskId, filePath, transcription];
}

final scriptCreateTableTaskPrompts = '''
CREATE TABLE ${Tables.taskPrompts} (
  ${TaskPromptFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TaskPromptFields.taskId} INTEGER UNIQUE NOT NULL,
  ${TaskPromptFields.filePath} TEXT NOT NULL,
  ${TaskPromptFields.transcription} TEXT,
  FOREIGN KEY (${TaskPromptFields.taskId}) REFERENCES ${Tables.tasks}(${TaskFields.id})
)
''';
