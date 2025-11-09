import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/tasks/task_seeds.dart';
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

  test('seedTasks inserts tasks and links to modules', () async {
    final db = await dbHelper.database;

    await seedModules(db);
    await seedTasks(db);

    final tasks = await db.query('tasks');
    expect(tasks.isNotEmpty, true);

    final modules = await db.query('modules');
    final moduleIds =
    modules.map((m) => m['module_id'] as int).toSet(); // adjust if needed

    for (final t in tasks) {
      final mid = t['module_id'] as int?;
      expect(moduleIds.contains(mid), true,
          reason: 'Task ${t['id']} has invalid module_id=$mid');
    }
  });
}
