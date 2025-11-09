import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/module/data/module_constants.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb(); // in-memory schema ready
  });

  tearDown(() async {
    await TestDatabaseHelper.delete(); // clean reset between tests
  });

  group('seedModules', () {
    test('inserts all expected modules', () async {
      final db = await dbHelper.database;

      await seedModules(db);

      final rows = await db.query(Tables.modules);

      expect(rows.isNotEmpty, true,
          reason: 'No modules were seeded into ${Tables.modules}');
      expect(
        rows.length,
        modulesList.length,
        reason:
        'Expected ${modulesList.length} modules, but found ${rows.length}',
      );
    });

    test('is idempotent (no duplicates on second run)', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      final first = await db.query(Tables.modules);

      await seedModules(db);
      final second = await db.query(Tables.modules);

      expect(
        second.length,
        first.length,
        reason: 'Modules were duplicated after running seedModules twice',
      );
    });

    test('module IDs are unique', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      final rows = await db.query(Tables.modules);

      final ids = rows
          .map((m) => m[ModuleFields.id] as int)
          .toList();
      final uniqueIds = ids.toSet();

      expect(
        uniqueIds.length,
        ids.length,
        reason: 'Duplicate module IDs found in ${Tables.modules}',
      );
    });
  });
}
