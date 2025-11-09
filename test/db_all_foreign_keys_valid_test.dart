import 'package:flutter_test/flutter_test.dart';

import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/seeders/seed_runner.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late SeedRunner seedRunner;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
    seedRunner = SeedRunner();
    await seedRunner.run(db: await dbHelper.database);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('All foreign keys reference existing rows', () async {
    final db = await dbHelper.database;

    // Get all user tables
    final tables = (await db.rawQuery('''
      SELECT name FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
    ''')).map((r) => r['name'] as String).toList();

    for (final table in tables) {
      // Introspect foreign keys for this table
      final fkRows = await db.rawQuery('PRAGMA foreign_key_list($table)');
      if (fkRows.isEmpty) continue;

      for (final fk in fkRows) {
        final parentTable = fk['table'] as String; // referenced table
        final fromCol = fk['from'] as String;      // child column
        final toCol = fk['to'] as String;          // parent column

        // Build parent set
        final parentRows = await db.query(
          parentTable,
          columns: [toCol],
        );

        final parentValues = parentRows
            .map((r) => r[toCol])
            .where((v) => v != null)
            .toSet();

        // Validate each child row
        final childRows = await db.query(
          table,
          columns: [fromCol, 'rowid'],
        );

        for (final row in childRows) {
          final value = row[fromCol];
          // Null allowed (depends on schema); we only assert when non-null
          if (value == null) continue;

          expect(
            parentValues.contains(value),
            true,
            reason:
            'FK violation: $table.$fromCol -> $parentTable.$toCol; '
                'rowid=${row['rowid']} has value=$value not found in $parentTable.$toCol',
          );
        }
      }
    }
  });
}
