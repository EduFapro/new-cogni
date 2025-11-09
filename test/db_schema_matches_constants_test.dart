import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/features/module/data/module_constants.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_constants.dart';
import 'package:segundo_cogni/features/task/data/task_constants.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_constants.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_constants.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';

import 'package:segundo_cogni/features/evaluator/data/evaluator_constants.dart';
import 'package:segundo_cogni/features/participant/data/participant_constants.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_constants.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb(); // this creates schema
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('Tables have columns matching their *Fields.values', () async {
    final db = await dbHelper.database;

    final Map<String, List<String>> expected = {
      Tables.evaluators: EvaluatorFields.values,
      Tables.participants: ParticipantFields.values,
      Tables.evaluations: EvaluationFields.values,
      Tables.modules: ModuleFields.values,
      Tables.tasks: TaskFields.values,
      Tables.taskPrompts: TaskPromptFields.values,
      Tables.moduleInstances: ModuleInstanceFields.values,
      Tables.taskInstances: TaskInstanceFields.values,
      Tables.recordings: RecordingFields.values,
      Tables.currentUser: CurrentUserFields.values,
    };

    for (final entry in expected.entries) {
      final table = entry.key;
      final expectedCols = entry.value.toSet();

      final pragma = await db.rawQuery('PRAGMA table_info($table)');
      final actualCols = pragma.map((c) => c['name'] as String).toSet();

      // 1) Every expected column exists
      expect(
        actualCols.containsAll(expectedCols),
        true,
        reason:
        'Table $table is missing columns from *Fields.values. '
            'Expected at least: $expectedCols, actual: $actualCols',
      );

      // 2) No unexpected columns
      expect(
        expectedCols.containsAll(actualCols),
        true,
        reason:
        'Table $table has extra columns not in *Fields.values. '
            'Expected only: $expectedCols, actual: $actualCols',
      );
    }
  });
}
