import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late ParticipantLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    ds = ParticipantLocalDataSource();
    await dbHelper.database; // schema already created
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insertParticipant and getAllParticipants', () async {
    final db = await dbHelper.database;

    int? id;
    await db.transaction((txn) async {
      id = await ds.insertParticipant(txn, {
        'name': 'John',
        'surname': 'Doe',
        'birth_date': '1990-01-01',
        'sex': 1,
        'education_level': 6,
      });
    });

    expect(id, isNotNull);

    final all = await ds.getAllParticipants();
    expect(all.length, 1);
    expect(all.first.name, 'John');
  });
}
