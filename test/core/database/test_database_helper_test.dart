import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/database/database_schema.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb(); // ✅ Ensures schema creation
  });

  tearDown(() async {
    await dbHelper.close(); // ✅ Ensures clean reset between tests
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
  }, timeout: Timeout(Duration(seconds: 5))); // ✅ Prevents hanging

  test('dropAll removes tables', () async {
    final db = await dbHelper.database;

    await DatabaseSchema.dropAll(db);
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    final names = result.map((e) => e['name'] as String).toSet();

    for (final table in ['evaluators', 'participants', 'evaluations']) {
      expect(names.contains(table), false);
    }
  }, timeout: Timeout(Duration(seconds: 5))); // ✅ Prevents hanging
}
