import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';

void main() {
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Future<Map<String, int>> _rowCounts(DatabaseExecutor db) async {
    final tables = <String>[
      Tables.evaluators,
      Tables.participants,
      Tables.modules,
      Tables.tasks,
      Tables.taskPrompts,
      Tables.evaluations,
      Tables.moduleInstances,
      Tables.taskInstances,
      Tables.recordings,
      Tables.currentUser,
    ];

    final result = <String, int>{};
    for (final t in tables) {
      final countRes = await db.rawQuery('SELECT COUNT(*) AS c FROM $t');
      result[t] = (countRes.first['c'] as int?) ?? 0;
    }
    return result;
  }

  test('SeedRunner.run is atomic when wrapped in a transaction', () async {
    final db = await dbHelper.database;

    // Snapshot BEFORE
    final before = await _rowCounts(db);

    // Try seeding inside a transaction but force a failure.
    try {
      await db.transaction((txn) async {
        // Run your real seeds here
        final runner = SeedRunner();
        await runner.run(db: txn); // requires db: DatabaseExecutor

        // Force an error AFTER some inserts
        throw Exception('Forced failure to test rollback');
      });
    } catch (_) {
      // expected
    }

    // Snapshot AFTER: should be identical if everything is atomic
    final after = await _rowCounts(db);

    expect(
      after,
      equals(before),
      reason:
      'SeedRunner.run is not atomic. '
          'Row counts changed despite transaction failure.\n'
          'Before: $before\nAfter:  $after',
    );
  });
}
