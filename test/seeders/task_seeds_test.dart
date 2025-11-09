import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';
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

  group('seedTasks', () {
    test('inserts all tasks after modules', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);

      final rows = await db.query(Tables.tasks);
      expect(rows.isNotEmpty, true);
      expect(rows.length, tasksList.length);
    });

    test('is idempotent', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      await seedTasks(db);
      final first = await db.query(Tables.tasks);

      await seedTasks(db);
      final second = await db.query(Tables.tasks);

      expect(second.length, first.length);
    });
  });
}
