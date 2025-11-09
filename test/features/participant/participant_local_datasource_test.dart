import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/enums/laterality_enums.dart';
import 'package:segundo_cogni/core/logger/app_logger.dart';
import 'package:segundo_cogni/features/participant/data/participant_constants.dart';
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
      ParticipantFields.name: 'Test User',
      ParticipantFields.surname: 'User',
      ParticipantFields.birthDate: '2000-01-01',       // must match schema
      ParticipantFields.sex: 1,                         // assuming numeric enum value
      ParticipantFields.educationLevel: 3,            // assuming numeric enum value
      ParticipantFields.laterality: Laterality.ambidextrous,
    });


    AppLogger.info('Test inserted participant with id=$id');
    expect(id, isNotNull);

    final participant = await dataSource.getById(id!);
    expect(participant?.name, equals('Test User'));
  });
}
