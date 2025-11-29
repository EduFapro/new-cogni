import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_local_datasource.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_repository_impl.dart';
import 'package:segundo_cogni/features/evaluator/domain/evaluator_registration_data.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late EvaluatorLocalDataSource localDataSource;
  late EvaluatorRepositoryImpl repository;

  setUp(() async {
    await TestDatabaseHelper.delete();
    await DeterministicEncryptionHelper.init();
    dbHelper = TestDatabaseHelper.instance;
    final db = await dbHelper.database;
    localDataSource = EvaluatorLocalDataSource(db);
    repository = EvaluatorRepositoryImpl(local: localDataSource);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('📝 insertEvaluator saves evaluator to DB', () async {
    final data = EvaluatorRegistrationData(
      name: 'John',
      surname: 'Doe',
      email: 'john.doe@example.com',
      username: 'johndoe',
      password: 'password123',
      birthDate: '1990-01-01',
      specialty: 'Psychology',
      cpf: '12345678900',
    );

    await repository.insertEvaluator(data);

    final evaluator = await localDataSource.getEvaluatorByEmail(data.email);
    expect(evaluator, isNotNull);
    expect(evaluator!.name, data.name);
    expect(evaluator.username, data.username);
    // Password should be hashed or at least stored
    expect(evaluator.password, isNotEmpty);
  });

  test('👮 hasAnyEvaluatorAdmin returns false when DB is empty', () async {
    final hasAdmin = await repository.hasAnyEvaluatorAdmin();
    expect(hasAdmin, isFalse);
  });
}
