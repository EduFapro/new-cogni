import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'datasources/evaluator_remote_datasource.dart';
import 'auth_local_datasource.dart';

import '../../../../shared/utils/password_helper.dart';
import '../../../../core/network.dart';
import '../../../../core/environment.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;
  final EvaluatorRemoteDataSource _remote;
  final NetworkService _network;

  final AppEnv _env;

  AuthRepositoryImpl(this._local, this._remote, this._network, this._env);

  @override
  Future<EvaluatorModel?> login(String emailOrUsername, String password) async {
    print('[AuthRepositoryImpl] 🔐 Login request for: $emailOrUsername');

    // 1. Try Remote Login (Only if NOT offline)
    String? token;
    if (_env != AppEnv.offline) {
      try {
        token = await _remote.login(emailOrUsername, password);
        if (token != null) {
          _network.setToken(token);
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
    } else {
      print('[AuthRepositoryImpl] 📴 Offline mode: Skipping remote login.');
    }

    // 2. Local Lookup (Fallback or Sync)
    final evaluator = await _local.getEvaluatorByEmail(emailOrUsername);

    if (evaluator == null) {
      print(
        '[AuthRepositoryImpl] ❌ No local evaluator found for $emailOrUsername',
      );
      return null;
    }

    // Verify password using BCrypt
    if (!PasswordHelper.verify(password, evaluator.password)) {
      print('[AuthRepositoryImpl] ❌ Password mismatch');
      return null;
    }

    print('[AuthRepositoryImpl] ✅ Local Login successful');

    // 3. Update Token if Remote Login Succeeded
    if (token != null) {
      _network.setToken(token);
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
  Future<void> signOut() async {
    _network.setToken(null);
    return _local.clearCurrentUser();
  }
}
