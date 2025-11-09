import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late SeedRunner seedRunner;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
    seedRunner = SeedRunner();
    await seedRunner.run(db: await dbHelper.database);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('Every task.module_id points to an existing module', () async {
    final db = await dbHelper.database;

    final modules = await db.query('modules');
    final tasks = await db.query('tasks');

    final moduleIds =
    modules.map((m) => m['module_id'] as int).toSet(); // adjust col name if needed

    for (final t in tasks) {
      final mid = t['module_id'] as int?;
      expect(mid != null && moduleIds.contains(mid), true,
          reason: 'Task ${t['id']} has invalid module_id=$mid');
    }
  });

  test('Every prompt.task_id points to an existing task', () async {
    final db = await dbHelper.database;

    final tasks = await db.query('tasks');
    final prompts = await db.query('task_prompts');

    final taskIds = tasks.map((t) => t['id'] as int).toSet(); // adjust col name if needed

    for (final p in prompts) {
      final tid = p['task_id'] as int?;
      expect(tid != null && taskIds.contains(tid), true,
          reason: 'Prompt ${p['prompt_id']} has invalid task_id=$tid');
    }
  });
}
