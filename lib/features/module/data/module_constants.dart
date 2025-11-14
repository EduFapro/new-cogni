// data/module_constants.dart

import '../../../core/constants/database_constants.dart';

class ModuleFields {
  static const String id = 'module_id';
  static const String title = 'title';

  static const List<String> values = [id, title];
}

const scriptCreateTableModules = '''
CREATE TABLE ${Tables.modules} (
  ${ModuleFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ModuleFields.title} TEXT NOT NULL
)
''';
