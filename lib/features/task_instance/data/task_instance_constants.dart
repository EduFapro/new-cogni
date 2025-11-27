import '../../../core/constants/database_constants.dart';
import '../../module_instance/data/module_instance_constants.dart';
import '../../task/data/task_constants.dart';

class TaskInstanceFields {
  static const id = 'task_inst_id';
  static const taskId = TaskFields.id;
  static const moduleInstanceId = ModuleInstanceFields.id;
  static const status = 'status';
  static const completingTime = 'task_completing_time';

  static const values = [id, taskId, moduleInstanceId, status, completingTime];
}

final scriptCreateTableTaskInstances = '''
CREATE TABLE ${Tables.taskInstances} (
  ${TaskInstanceFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${TaskInstanceFields.taskId} INTEGER NOT NULL,
  ${TaskInstanceFields.moduleInstanceId} INTEGER NOT NULL,
  ${TaskInstanceFields.status} INT NOT NULL CHECK(${TaskInstanceFields.status} IN (1, 2, 3)),
  ${TaskInstanceFields.completingTime} TEXT,
  FOREIGN KEY (${TaskInstanceFields.taskId}) REFERENCES ${Tables.tasks}(${TaskFields.id}),
  FOREIGN KEY (${TaskInstanceFields.moduleInstanceId}) REFERENCES ${Tables.moduleInstances}(${ModuleInstanceFields.id})
)
''';
