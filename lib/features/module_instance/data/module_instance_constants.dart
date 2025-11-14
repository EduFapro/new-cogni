import '../../../core/constants/database_constants.dart';
import '../../evaluation/data/evaluation_constants.dart';
import '../../module/data/module_constants.dart';

class ModuleInstanceFields {
  static const id = 'module_inst_id';
  static const moduleId = ModuleFields.id;
  static const evaluationId = EvaluationFields.id;
  static const status = 'status';

  static const values = [id, moduleId, evaluationId, status];
}

const scriptCreateTableModuleInstances = '''
CREATE TABLE ${Tables.moduleInstances} (
  ${ModuleInstanceFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ModuleInstanceFields.moduleId} INTEGER NOT NULL,
  ${ModuleInstanceFields.evaluationId} INTEGER NOT NULL,
  ${ModuleInstanceFields.status} INT NOT NULL CHECK(${ModuleInstanceFields.status} >= 1 AND ${ModuleInstanceFields.status} <= 3),
  FOREIGN KEY (${ModuleInstanceFields.moduleId}) REFERENCES ${Tables.modules}(${ModuleFields.id})
)
''';
