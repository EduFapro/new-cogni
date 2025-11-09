import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';

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

  group('SeedRunner', () {
    test('seeds all core data sets', () async {
      final db = await dbHelper.database;
      final runner = SeedRunner();

      await runner.run(db: db);

      final modules = await db.query(Tables.modules);
      final tasks = await db.query(Tables.tasks);
      final prompts = await db.query(Tables.taskPrompts);

      expect(modules.isNotEmpty, true);
      expect(tasks.isNotEmpty, true);
      expect(prompts.isNotEmpty, true);
    });

    test('is safe to run multiple times', () async {
      final db = await dbHelper.database;
      final runner = SeedRunner();

      await runner.run(db: db);
      final firstModules = await db.query(Tables.modules);
      final firstTasks = await db.query(Tables.tasks);
      final firstPrompts = await db.query(Tables.taskPrompts);

      await runner.run(db: db);
      final secondModules = await db.query(Tables.modules);
      final secondTasks = await db.query(Tables.tasks);
      final secondPrompts = await db.query(Tables.taskPrompts);

      expect(secondModules.length, firstModules.length);
      expect(secondTasks.length, firstTasks.length);
      expect(secondPrompts.length, firstPrompts.length);
    });
  });
}
