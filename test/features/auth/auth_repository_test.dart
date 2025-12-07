import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/auth/data/auth_local_datasource.dart';
import 'package:segundo_cogni/features/auth/data/auth_repository_impl.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';
import 'package:segundo_cogni/features/evaluator/application/evaluator_secure_service.dart';
import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';

import 'package:segundo_cogni/features/auth/data/datasources/evaluator_remote_datasource.dart';
import 'package:segundo_cogni/core/network.dart';
import 'package:segundo_cogni/core/environment.dart';

class MockEvaluatorRemoteDataSource implements EvaluatorRemoteDataSource {
  @override
  Future<String?> login(String username, String password) async {
    return null; // Default to no token for existing tests
  }

  @override
  Future<Map<String, dynamic>?> getEvaluatorById(int id) async {
    return null;
  }
}

class MockNetworkService extends NetworkService {
  @override
  void setToken(String? token) {}
}

void main() {
  late TestDatabaseHelper dbHelper;
  late AuthLocalDataSource authDataSource;
  late AuthRepositoryImpl authRepository;
  late MockNetworkService mockNetworkService;

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
    // Insert into evaluators table first (needed for login and FK)
    final encrypted = await EvaluatorSecureService.encrypt(dummyUser);
    final db = await dbHelper.database;
    await db.insert('evaluators', encrypted.toEvaluatorTableMap());

    // Also save as current user
    await authDataSource.saveCurrentUser(dummyUser);
  }

  setUp(() async {
    await TestDatabaseHelper.delete();
    await DeterministicEncryptionHelper.init();
    dbHelper = TestDatabaseHelper.instance;
    final db = await dbHelper.database;
    authDataSource = AuthLocalDataSource(db);
    mockNetworkService = MockNetworkService();
    authRepository = AuthRepositoryImpl(
      authDataSource,
      MockEvaluatorRemoteDataSource(),
      mockNetworkService,
      AppEnv.offline,
    );
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

  test(
    '🧠 Evaluator is NOT encrypted (except password) before storage',
    () async {
      final encrypted = await EvaluatorSecureService.encrypt(dummyUser);

      expect(encrypted.name, dummyUser.name);
      expect(encrypted.email, dummyUser.email);
      expect(encrypted.password.length, 60); // BCrypt hash length
    },
  );

  test('🛡️ Raw DB data is NOT encrypted (except password)', () async {
    await seedUser();

    final raw = await dbHelper.database.then((db) => db.query('current_user'));
    expect(raw.first['email'], dummyUser.email);
    expect(raw.first['name'], dummyUser.name);
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
