import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';

void main() {
  late ParticipantLocalDataSource dataSource;

  setUp(() async {
    final dbHelper = TestDatabaseHelper.instance;
    await dbHelper.initDb();
    dataSource = ParticipantLocalDataSource(dbHelper: dbHelper);
  });

  test('insert and retrieve participant', () async {
    final db = await TestDatabaseHelper.instance.database;

    final id = await dataSource.insertParticipant(db, {
      'name': 'Test User',
    });

    expect(id, isNotNull);

    final participant = await dataSource.getById(id!);
    expect(participant?.name, equals('Test User'));
  });
}
