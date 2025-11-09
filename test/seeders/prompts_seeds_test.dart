import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/features/task/data/task_constants.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_constants.dart';
import 'package:segundo_cogni/seeders/tasks/task_seeds.dart';
import 'package:segundo_cogni/seeders/prompts/prompts_seed.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('seedPrompts inserts prompts and links to tasks', () async {
    final db = await dbHelper.database;

    await seedModules(db);
    await seedTasks(db);
    await seedPrompts(db);

    final prompts = await db.query(Tables.taskPrompts);
    expect(prompts.isNotEmpty, true);

    final tasks = await db.query(Tables.tasks);
    final taskIds =
    tasks.map((t) => t[TaskFields.id] as int).toSet(); // ✅ correct key

    for (final p in prompts) {
      final tid = p[TaskPromptFields.taskID] as int?;
      expect(
        taskIds.contains(tid),
        true,
        reason: 'Prompt ${p[TaskPromptFields.promptID]} has invalid task_id=$tid',
      );
    }
  });
}
