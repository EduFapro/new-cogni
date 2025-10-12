import '../../../core/constants/database_constants.dart';

class TaskFields {
  static const id = 'task_id';
  static const moduleId = 'module_id';
  static const title = 'title';
  static const transcript = 'transcript';
  static const mode = 'mode';
  static const position = 'position';
  static const imagePath = 'image_path';
  static const timeForCompletion = 'time_for_completion';
  static const mayRepeatPrompt = 'may_repeat_prompt';
  static const testOnly = 'test_only';

  static const values = [
    id,
    moduleId,
    title,
    transcript,
    mode,
    position,
    imagePath,
    timeForCompletion,
    mayRepeatPrompt,
    testOnly,
  ];
}

const scriptCreateTableTasks = '''
CREATE TABLE ${Tables.tasks} (
  ${TaskFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TaskFields.moduleId} INTEGER NOT NULL,
  ${TaskFields.title} TEXT NOT NULL,
  ${TaskFields.transcript} TEXT,
  ${TaskFields.mode} INTEGER NOT NULL,
  ${TaskFields.position} INTEGER NOT NULL,
  ${TaskFields.imagePath} TEXT NOT NULL,
  ${TaskFields.mayRepeatPrompt} INTEGER NOT NULL,
  ${TaskFields.testOnly} INTEGER NOT NULL,
  ${TaskFields.timeForCompletion} INTEGER NOT NULL,
  FOREIGN KEY (${TaskFields.moduleId}) REFERENCES ${Tables.modules}(${TaskFields.id}),
  CHECK(${TaskFields.mode} >= 0 AND ${TaskFields.mode} <= 1),
  CHECK(${TaskFields.mayRepeatPrompt} >= 0 AND ${TaskFields.mayRepeatPrompt} <= 1)
)
''';
