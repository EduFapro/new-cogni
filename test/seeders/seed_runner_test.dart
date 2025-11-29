import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';

void main() {
  // Needed when using any Flutter bindings or sqflite FFI in tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDatabaseHelper dbHelper;
  late SeedRunner seedRunner;

  setUp(() async {
    await DeterministicEncryptionHelper.init();
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb(); // ✅ ensures schema exists (in-memory)
    seedRunner = SeedRunner();
  });

  tearDown(() async {
    // ✅ resets the in-memory DB between tests
    await TestDatabaseHelper.delete();
  });

  group('SeedRunner', () {
    test('seeds modules, tasks, prompts and evaluator', () async {
      final db = await dbHelper.database;

      await seedRunner.run(db: db);

      final modules = await db.query(Tables.modules);
      final tasks = await db.query(Tables.tasks);
      final prompts = await db.query(Tables.taskPrompts);
      final evaluators = await db.query(Tables.evaluators);

      expect(modules.isNotEmpty, true, reason: 'No modules were seeded');
      expect(tasks.isNotEmpty, true, reason: 'No tasks were seeded');
      expect(prompts.isNotEmpty, true, reason: 'No prompts were seeded');
      expect(evaluators.isNotEmpty, true, reason: 'No evaluator was seeded');
    });

    test('is idempotent (no duplicates on second run)', () async {
      final db = await dbHelper.database;

      await seedRunner.run(db: db);
      final firstModules = await db.query(Tables.modules);
      final firstTasks = await db.query(Tables.tasks);
      final firstPrompts = await db.query(Tables.taskPrompts);
      final firstEvaluators = await db.query(Tables.evaluators);

      await seedRunner.run(db: db);
      final secondModules = await db.query(Tables.modules);
      final secondTasks = await db.query(Tables.tasks);
      final secondPrompts = await db.query(Tables.taskPrompts);
      final secondEvaluators = await db.query(Tables.evaluators);

      expect(
        secondModules.length,
        firstModules.length,
        reason: 'Modules duplicated after second seeding',
      );
      expect(
        secondTasks.length,
        firstTasks.length,
        reason: 'Tasks duplicated after second seeding',
      );
      expect(
        secondPrompts.length,
        firstPrompts.length,
        reason: 'Prompts duplicated after second seeding',
      );
      expect(
        secondEvaluators.length,
        firstEvaluators.length,
        reason: 'Evaluators duplicated after second seeding',
      );
    });
  });
}
