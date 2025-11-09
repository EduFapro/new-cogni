import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/features/module/data/module_constants.dart';
import 'package:segundo_cogni/features/task/data/task_constants.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_constants.dart';
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

  group('Seed relations', () {
    test('Every task.module_id points to an existing module', () async {
      final db = await dbHelper.database;

      final modules = await db.query(Tables.modules);
      final tasks = await db.query(Tables.tasks);

      final moduleIds =
      modules.map((m) => m[ModuleFields.id] as int).toSet();

      for (final t in tasks) {
        final mid = t[TaskFields.moduleId] as int?;
        expect(
          mid != null && moduleIds.contains(mid),
          true,
          reason:
          'Task ${t[TaskFields.id]} has invalid module_id=$mid (not found in ${Tables.modules})',
        );
      }
    });

    test('Every prompt.task_id points to an existing task', () async {
      final db = await dbHelper.database;

      final tasks = await db.query(Tables.tasks);
      final prompts = await db.query(Tables.taskPrompts);

      final taskIds =
      tasks.map((t) => t[TaskFields.id] as int).toSet();

      for (final p in prompts) {
        final tid = p[TaskPromptFields.taskID] as int?;
        expect(
          tid != null && taskIds.contains(tid),
          true,
          reason:
          'Prompt ${p[TaskPromptFields.promptID]} has invalid task_id=$tid (not found in ${Tables.tasks})',
        );
      }
    });
  });
}
