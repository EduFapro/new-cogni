import '../../../core/constants/database_constants.dart';
import '../../task/data/task_constants.dart';

class TaskPromptFields {
  static const promptID = 'prompt_id';
  static const taskId = TaskFields.id;
  static const filePath = 'file_path';
  static const transcription = 'transcription';

  static const values = [promptID, taskId, filePath, transcription];
}

final scriptCreateTableTaskPrompts = '''
CREATE TABLE ${Tables.taskPrompts} (
  ${TaskPromptFields.promptID} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TaskPromptFields.taskId} INTEGER UNIQUE NOT NULL,
  ${TaskPromptFields.filePath} TEXT NOT NULL,
  ${TaskPromptFields.transcription} TEXT,
  FOREIGN KEY (${TaskPromptFields.taskId}) REFERENCES ${Tables.tasks}(${TaskFields.id})
)
''';
