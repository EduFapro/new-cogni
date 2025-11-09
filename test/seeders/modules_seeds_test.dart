import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';

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

  group('seedModules', () {
    test('inserts all modules', () async {
      final db = await dbHelper.database;

      await seedModules(db);

      final rows = await db.query(Tables.modules);
      expect(rows.isNotEmpty, true);
      expect(rows.length, 5);
    });

    test('is idempotent', () async {
      final db = await dbHelper.database;

      await seedModules(db);
      final first = await db.query(Tables.modules);

      await seedModules(db);
      final second = await db.query(Tables.modules);

      expect(second.length, first.length);
    });
  });
}
