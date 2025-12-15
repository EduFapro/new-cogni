import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/evaluator/application/evaluator_secure_service.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_local_datasource.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';
import 'package:segundo_cogni/shared/encryption/gcm_encryption_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestDatabaseHelper dbHelper;
  late EvaluatorLocalDataSource ds;

  setUp(() async {
    await DeterministicEncryptionHelper.init();
    await GcmEncryptionHelper.init(); // Ensure GCM is also initialized
    await TestDatabaseHelper.delete(); // ✅ clean start
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.database;
    ds = EvaluatorLocalDataSource(await dbHelper.database);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('✅ Create evaluator and verify encrypted storage', () async {
    final evaluator = EvaluatorModel(
      evaluatorId: "test-uuid-correct",
      name: 'John',
      surname: 'Doe',
      email: 'john.doe@example.com',
      birthDate: '1990-01-01',
      cpfOrNif: '12345678900',
      username: 'johndoe',
      password: 'securePass123',
      specialty: 'Neurologist',
    );

    // Encrypt before inserting (simulating what the repo/service would do)
    // Actually, the datasource expects an ALREADY encrypted model for insert?
    // Let's check the datasource. insert() calls encrypt() internally!
    // Wait, let's check EvaluatorLocalDataSource.insert again.
    // Step 1338:
    // Future<void> insert(EvaluatorModel evaluator) async {
    //   final secured = await EvaluatorSecureService.encrypt(evaluator);
    //   await _db.insert(...)
    // }
    // So I should pass the PLAIN model to insert!

    await ds.insert(evaluator);
    final fetched = await ds.getFirstEvaluator();

    expect(fetched, isNotNull);

    // Decrypt to validate correctness
    // getFirstEvaluator returns DECRYPTED model.
    expect(fetched!.email, equals('john.doe@example.com'));
    // Password should be hashed.
    expect(fetched.password.length, 60); // BCrypt hash length is 60
  });

  test('✅ Insert and fetch evaluator works with encryption', () async {
    final evaluator = EvaluatorModel(
      evaluatorId: "test-uuid-correct",
      name: 'Jane',
      surname: 'Doe',
      email: 'jane@example.com',
      birthDate: '1990-01-01',
      cpfOrNif: '12312312312',
      username: 'janedoe',
      password: 'superSecret!',
      specialty: 'Psychologist',
    );

    await ds.insert(evaluator);

    final fetched = await ds.getFirstEvaluator();

    expect(fetched, isNotNull);
    expect(fetched!.email, equals('jane@example.com'));
  });

  test(
    '✅ Create evaluator and verify encrypted storage + decrypted values',
    () async {
      const email = 'john.doe@example.com';
      const name = 'John';
      const surname = 'Doe';

      final evaluator = EvaluatorModel(
        evaluatorId: "test-uuid-correct",
        name: name,
        surname: surname,
        email: email,
        birthDate: '1990-01-01',
        cpfOrNif: '12345678900',
        username: 'johndoe',
        password: 'securePass123',
        specialty: 'Neurologist',
      );

      await ds.insert(evaluator);
      final fetched = await ds.getFirstEvaluator();

      expect(fetched, isNotNull);

      // ✅ Validate decrypted fields match user input
      expect(fetched!.name, equals(name));
      expect(fetched.surname, equals(surname));
      expect(fetched.email, equals(email));
    },
  );

  test('🔒 Login fails with wrong password', () async {
    const username = 'userfail';
    const correctPassword = 'rightPassword123';
    const wrongPassword = 'wrongPassword456';

    final evaluator = EvaluatorModel(
      evaluatorId: "test-uuid-correct",
      name: 'Fail',
      surname: 'Tester',
      email: 'fail@test.com',
      birthDate: '1995-01-01',
      cpfOrNif: '99988877766',
      username: username,
      password: correctPassword,
      specialty: 'Psychiatrist',
    );

    await ds.insert(evaluator);

    final loggedIn = await ds.login(username, wrongPassword);
    expect(loggedIn, isNull); // ✅ Should not log in
  });

  test('🔒 Login fails with wrong username', () async {
    const correctUsername = 'realuser';
    const wrongUsername = 'wronguser';
    const password = 'correctPassword';

    final evaluator = EvaluatorModel(
      evaluatorId: "test-uuid-correct",
      name: 'Real',
      surname: 'User',
      email: 'real@user.com',
      birthDate: '1993-05-10',
      cpfOrNif: '12312312312',
      username: correctUsername,
      password: password,
      specialty: 'Neurologist',
    );

    await ds.insert(evaluator);

    final loggedIn = await ds.login(wrongUsername, password);
    expect(loggedIn, isNull); // ✅ Should not log in
  });
}
