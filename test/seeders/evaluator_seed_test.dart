// test/seeders/evaluator_seed_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/evaluators/evaluator_seed.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('seedDummyEvaluator inserts at least one evaluator', () async {
    final db = await dbHelper.database;

    // ✅ call without named parameter
    await seedDummyEvaluator();

    final evaluators = await db.query('evaluators');
    expect(evaluators.isNotEmpty, true,
        reason: 'No evaluator was seeded into evaluators table');
  });
}
