import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/evaluators/evaluator_seed.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    await DeterministicEncryptionHelper.init();
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('seedDummyEvaluator inserts at least one evaluator', () async {
    final db = await dbHelper.database;

    await seedDummyEvaluator(db);

    final evaluators = await db.query('evaluators');
    expect(evaluators.isNotEmpty, true, reason: 'No evaluator was seeded');
  });
}
