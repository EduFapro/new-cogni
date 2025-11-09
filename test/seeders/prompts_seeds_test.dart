import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';
import 'package:segundo_cogni/seeders/prompts/prompts_seed.dart';
import 'package:segundo_cogni/seeders/tasks/task_seeds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
  });

  tearDown(() async {
    await TestDatabaseHelper.delete();
  });

  group('seedPrompts', () {
    test('inserts all prompts after tasks', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);

      final rows = await db.query(Tables.taskPrompts);
      expect(rows.isNotEmpty, true);
      expect(rows.length, tasksPromptsList.length);
    });

    test('is idempotent', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);
      final first = await db.query(Tables.taskPrompts);

      await seedPrompts(db);
      final second = await db.query(Tables.taskPrompts);

      expect(second.length, first.length);
    });
  });
}
