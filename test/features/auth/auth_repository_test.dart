import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/auth/data/auth_local_datasource.dart';
import 'package:segundo_cogni/features/auth/data/auth_repository_impl.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model_extensions.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late AuthLocalDataSource authDataSource;
  late AuthRepositoryImpl authRepository;

  final dummyUser = EvaluatorModel(
    evaluatorId: null,
    name: 'Edu',
    surname: 'Fapro',
    email: 'edu@gmail.com',
    birthDate: '1990-01-01',
    cpfOrNif: '12345678900',
    username: 'edufapro',
    password: 'password123',
    specialty: 'Neuro',
  ).encryptedAndHashed();

  setUp(() async {
    await TestDatabaseHelper.delete();
    dbHelper = TestDatabaseHelper.instance;
    final db = await dbHelper.database;
    authDataSource = AuthLocalDataSource(db);
    authRepository = AuthRepositoryImpl(authDataSource);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('🚪 Logout clears current user from DB', () async {
    await authDataSource.saveCurrentUser(dummyUser);
    final cached = await authDataSource.getCachedUser();
    expect(cached, isNotNull);

    await authRepository.signOut();

    final afterLogout = await authDataSource.getCachedUser();
    expect(afterLogout, isNull);
  });

  test('🚀 Auto-login loads cached user from DB', () async {
    await authDataSource.saveCurrentUser(dummyUser);
    final user = await authRepository.fetchCurrentUserOrNull();
    expect(user, isNotNull);
    expect(user!.email, equals('edu@gmail.com'));
  });

  test('🧠 Evaluator is encrypted before storage', () {
    expect(dummyUser.name, isNot(equals('Edu')));
    expect(dummyUser.email, isNot(equals('edu@gmail.com')));
    expect(dummyUser.password.length, 64); // SHA-256 hash
  });

  test('🛡️ Saved user is encrypted in DB', () async {
    await authDataSource.saveCurrentUser(dummyUser);

    final raw = await dbHelper.database.then(
          (db) => db.query('current_user', limit: 1),
    );

    expect(raw.first['email'], isNot('edu@gmail.com'));
    expect(raw.first['name'], isNot('Edu'));
  });

  test('❌ fetchCurrentUserOrNull returns null if not saved', () async {
    final user = await authRepository.fetchCurrentUserOrNull();
    expect(user, isNull);
  });
}
