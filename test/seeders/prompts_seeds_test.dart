import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';
import 'package:segundo_cogni/seeders/prompts/prompts_seed.dart';
import 'package:segundo_cogni/seeders/tasks/task_seeds.dart';
import 'package:segundo_cogni/features/task/data/task_constants.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb(); // in-memory test DB + schema
  });

  tearDown(() async {
    await TestDatabaseHelper.delete(); // reset between tests
  });

  group('seedPrompts', () {
    test('inserts all prompts after modules and tasks', () async {
      final db = await dbHelper.database;

      // order matters: modules → tasks → prompts
      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);

      final prompts = await db.query(Tables.taskPrompts);

      expect(prompts.isNotEmpty, true,
          reason: 'No prompts were seeded into ${Tables.taskPrompts}');
      expect(prompts.length, tasksPromptsList.length,
          reason:
          'Seeded ${prompts.length} prompts but expected ${tasksPromptsList.length}');
    });

    test('is idempotent (no duplicates on second run)', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);
      final first = await db.query(Tables.taskPrompts);

      await seedPrompts(db);
      final second = await db.query(Tables.taskPrompts);

      expect(second.length, first.length,
          reason: 'Prompts duplicated after running seedPrompts twice');
    });

    test('each prompt is linked to an existing task', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);

      final prompts = await db.query(Tables.taskPrompts);
      final tasks = await db.query(Tables.tasks);

      final taskIds =
      tasks.map((t) => t[TaskFields.id] as int).toSet(); // existing tasks

      for (final p in prompts) {
        final promptId = p[TaskPromptFields.promptID];
        final taskId = p[TaskPromptFields.taskID] as int?;
        expect(taskId, isNotNull,
            reason:
            'Prompt $promptId has null task_id in ${Tables.taskPrompts}');
        expect(taskIds.contains(taskId), true,
            reason:
            'Prompt $promptId references non-existent task_id=$taskId');
      }
    });
  });
}
