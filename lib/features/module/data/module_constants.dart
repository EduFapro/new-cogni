import '../../../core/constants/database_constants.dart';

class ModuleFields {
  static const id = 'module_id';
  static const title = 'title';

  static const values = [id, title];
}

const scriptCreateTableModules = '''
CREATE TABLE ${Tables.modules} (
  ${ModuleFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ModuleFields.title} TEXT NOT NULL
)
''';
