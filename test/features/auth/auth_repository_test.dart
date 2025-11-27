import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/auth/data/auth_local_datasource.dart';
import 'package:segundo_cogni/features/auth/data/auth_repository_impl.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';
import 'package:segundo_cogni/features/evaluator/application/evaluator_secure_service.dart';

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
  );

  Future<void> seedUser() async {
    await authDataSource.saveCurrentUser(dummyUser);
  }

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
    await seedUser();
    expect(await authDataSource.getCachedUser(), isNotNull);

    await authRepository.signOut();
    expect(await authDataSource.getCachedUser(), isNull);
  });

  test('🧠 Evaluator is encrypted before storage', () {
    final encrypted = EvaluatorSecureService.encrypt(dummyUser);

    expect(encrypted.name, isNot(dummyUser.name));
    expect(encrypted.email, isNot(dummyUser.email));
    expect(encrypted.password.length, 64); // SHA-256
  });

  test('🛡️ Raw DB data is encrypted', () async {
    await seedUser();

    final raw = await dbHelper.database.then((db) => db.query('current_user'));
    expect(raw.first['email'], isNot(dummyUser.email));
    expect(raw.first['name'], isNot(dummyUser.name));
  });

  test('❌ fetchCurrentUserOrNull returns null when DB is empty', () async {
    final user = await authRepository.fetchCurrentUserOrNull();
    expect(user, isNull);
  });

  test('🚀 Auto-login returns correct decrypted user from DB', () async {
    await seedUser();
    final user = await authRepository.fetchCurrentUserOrNull();

    expect(user, isNotNull);
    expect(user!.email, dummyUser.email);
    expect(user.name, dummyUser.name);
    expect(user.username, dummyUser.username);
  });

  test('🔐 Login returns user on correct credentials', () async {
    await seedUser();
    final user = await authRepository.login(
      dummyUser.email,
      dummyUser.password,
    );
    expect(user, isNotNull);
    expect(user!.email, dummyUser.email);
  });

  test('❌ Login returns null on wrong password', () async {
    await seedUser();
    final user = await authRepository.login(dummyUser.email, 'wrongpassword');
    expect(user, isNull);
  });

  test('❌ Login returns null on non-existent user', () async {
    final user = await authRepository.login(
      'nonexistent@example.com',
      'password',
    );
    expect(user, isNull);
  });
}
