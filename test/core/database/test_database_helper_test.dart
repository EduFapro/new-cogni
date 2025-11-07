import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/database/database_schema.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('creates all expected tables', () async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    final names = result.map((e) => e['name'] as String).toSet();

    for (final table in [
      'evaluators',
      'participants',
      'evaluations',
      'modules',
      'tasks',
      'task_prompts',
      'module_instances',
      'task_instances',
      'recordings',
    ]) {
      expect(names.contains(table), true, reason: 'Missing table: $table');
    }
  });

  test('dropAll removes tables', () async {
    final db = await dbHelper.database;

    await DatabaseSchema.dropAll(db);
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    final names = result.map((e) => e['name'] as String).toSet();

    // core sqlite tables will still exist; we just assert ours are gone
    for (final table in [
      'evaluators',
      'participants',
      'evaluations',
    ]) {
      expect(names.contains(table), false);
    }
  });
}
