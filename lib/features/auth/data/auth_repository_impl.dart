import '../../auth/domain/auth_repository.dart';
import '../../evaluator/application/evaluator_secure_service.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'datasources/evaluator_remote_datasource.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;
  final EvaluatorRemoteDataSource _remote;

  AuthRepositoryImpl(this._local, this._remote);

  @override
  Future<EvaluatorModel?> login(String emailOrUsername, String password) async {
    print('[AuthRepositoryImpl] 🔐 Login request for: $emailOrUsername');

    // 1. Try Remote Login
    String? token;
    try {
      token = await _remote.login(emailOrUsername, password);
      if (token != null) {
        print(
          '[AuthRepositoryImpl] ☁️ Remote login successful. Token received.',
        );
      } else {
        print(
          '[AuthRepositoryImpl] ☁️ Remote login failed or returned no token.',
        );
      }
    } catch (e) {
      print('[AuthRepositoryImpl] ⚠️ Remote login error: $e');
    }

    // 2. Local Lookup (Fallback or Sync)
    final evaluator = await _local.getEvaluatorByEmail(emailOrUsername);

    if (evaluator == null) {
      print(
        '[AuthRepositoryImpl] ❌ No local evaluator found for $emailOrUsername',
      );
      return null;
    }

    // Hash password instead of encrypting it
    final hashedInputPassword = EvaluatorSecureService.hash(password);

    if (evaluator.password != hashedInputPassword) {
      print('[AuthRepositoryImpl] ❌ Password mismatch');
      return null;
    }

    print('[AuthRepositoryImpl] ✅ Local Login successful');

    // 3. Update Token if Remote Login Succeeded
    if (token != null) {
      final updatedEvaluator = evaluator.copyWith(token: token);
      await _local.saveCurrentUser(updatedEvaluator);
      return updatedEvaluator;
    }

    return evaluator;
  }

  @override
  Future<void> saveCurrentUserToDB(EvaluatorModel user) {
    return _local.saveCurrentUser(user);
  }

  @override
  Future<EvaluatorModel?> getCachedUser() {
    return _local.getCachedUser();
  }

  @override
  Future<void> clearCurrentUser() {
    return _local.clearCurrentUser();
  }

  @override
  Future<void> clearCurrentUserFromDB() {
    return _local.clearCurrentUser();
  }

  @override
  Future<void> cacheUser(EvaluatorModel user) {
    // Optional: implement this if different from saveCurrentUserToDB
    return _local.saveCurrentUser(user);
  }

  @override
  Future<void> clearCachedUser() {
    return _local.clearCurrentUser();
  }

  @override
  Future<EvaluatorModel?> fetchCurrentUserOrNull() {
    return _local.getCachedUser();
  }

  @override
  Future<void> signOut() {
    return _local.clearCurrentUser();
  }
}
