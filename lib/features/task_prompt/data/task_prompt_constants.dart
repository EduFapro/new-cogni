import '../../../core/constants/database_constants.dart';
import '../../task/data/task_constants.dart';

class TaskPromptFields {
  static const promptID = 'prompt_id';
  static const taskID = TaskFields.id;
  static const filePath = 'file_path';
  static const transcription = 'transcription';

  static const values = [promptID, taskID, filePath, transcription];
}

final scriptCreateTableTaskPrompts = '''
CREATE TABLE ${Tables.taskPrompts} (
  ${TaskPromptFields.promptID} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TaskPromptFields.taskID} INTEGER UNIQUE NOT NULL,
  ${TaskPromptFields.filePath} TEXT NOT NULL,
  ${TaskPromptFields.transcription} TEXT,
  FOREIGN KEY (${TaskPromptFields.taskID}) REFERENCES ${Tables.tasks}(${TaskFields.id})
)
''';
