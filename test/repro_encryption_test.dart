import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';
import 'package:segundo_cogni/features/participant/domain/participant_entity.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';
import 'package:segundo_cogni/core/constants/enums/person_enums.dart';
import 'package:segundo_cogni/core/constants/enums/laterality_enums.dart';
import 'package:segundo_cogni/core/database/database_schema.dart';

class TestDatabaseHelper extends BaseDatabaseHelper {
  final Database _db;
  TestDatabaseHelper(this._db) : super('test.db');

  @override
  Future<Database> get database async => _db;

  @override
  Future<void> onCreate(Database db, int version) async {}
}

void main() {
  late Database db;
  late ParticipantLocalDataSource dataSource;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DeterministicEncryptionHelper.init();
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await DatabaseSchema.createAll(db);
    dataSource = ParticipantLocalDataSource(dbHelper: TestDatabaseHelper(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('Participant encryption/decryption round trip', () async {
    final participant = ParticipantEntity(
      name: 'John',
      surname: 'Doe',
      birthDate: DateTime(1990, 1, 1),
      sex: Sex.male,
      educationLevel: EducationLevel.completeCollege,
      laterality: Laterality.rightHanded,
    );

    // 1. Insert (should encrypt)
    // Note: Repository calls toMap(), so we simulate that here
    final map = participant.toMap();
    print('Encrypted Map: $map');
    await dataSource.insertParticipant(db, map);

    // 2. Read (should decrypt)
    final participants = await dataSource.getAllParticipants();
    expect(participants.length, 1);
    final fetched = participants.first;

    print('Fetched Name: ${fetched.name}');
    print('Fetched Surname: ${fetched.surname}');

    expect(fetched.name, 'John');
    expect(fetched.surname, 'Doe');
  });
}
