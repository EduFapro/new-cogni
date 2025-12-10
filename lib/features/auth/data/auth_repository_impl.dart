import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'datasources/evaluator_remote_datasource.dart';
import 'auth_local_datasource.dart';

import '../../../../shared/utils/password_helper.dart';
import '../../../../core/network.dart';
import '../../../../core/environment.dart';

import '../../../../shared/utils/jwt_helper.dart';

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
    EvaluatorModel? remoteUser;

    if (_env != AppEnv.offline) {
      try {
        token = await _remote.login(emailOrUsername, password);
        if (token != null) {
          _network.setToken(token);
          print(
            '[AuthRepositoryImpl] ☁️ Remote login successful. Token received.',
          );

          // Sync Remote User to Local DB
          final userId = JwtHelper.getUserId(token);
          if (userId != null) {
            final userData = await _remote.getEvaluatorById(userId);
            if (userData != null) {
              remoteUser = EvaluatorModel.fromJson(
                userData,
              ).copyWith(token: token);
              // Save/Update local DB with remote data
              await _local.saveCurrentUser(remoteUser);
              print('[AuthRepositoryImpl] 🔄 Synced remote user to local DB.');
            }
          }
        } else {
          print(
            '[AuthRepositoryImpl] ☁️ Remote login failed or returned no token.',
          );
          // CRITICAL: If remote login fails in online mode, DO NOT FALLBACK.
          // This prevents "ghost" logins when backend is down or credentials are wrong on backend.
          return null;
        }
      } catch (e) {
        print('[AuthRepositoryImpl] ⚠️ Remote login error: $e');
        // CRITICAL: If connection error occurs in online mode, DO NOT FALLBACK.
        return null;
      }
    } else {
      print('[AuthRepositoryImpl] 📴 Offline mode: Skipping remote login.');
    }

    // 2. Local Lookup (Fallback or Sync)
    // If we just synced the user, this will find it.
    final evaluator = await _local.getEvaluatorByEmail(emailOrUsername);

    if (evaluator == null) {
      print(
        '[AuthRepositoryImpl] ❌ No local evaluator found for $emailOrUsername',
      );
      return null;
    }

    // Verify password using BCrypt (only if not already verified by remote)
    // If we have a remote token, we know the password is correct for the remote user.
    // However, to be safe and consistent, we can check local password hash.
    // BUT, if we just synced, the password hash from remote might be different or we might have just saved it.
    // If remote login succeeded (token != null), we can skip local password check OR ensure we updated the password hash.

    if (token == null) {
      if (!PasswordHelper.verify(password, evaluator.password)) {
        print('[AuthRepositoryImpl] ❌ Password mismatch');
        return null;
      }
    }

    print('[AuthRepositoryImpl] ✅ Login successful');

    // 3. Update Token if Remote Login Succeeded (Redundant if we synced above, but safe)
    if (token != null && evaluator.token != token) {
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

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) {
    if (_env == AppEnv.offline) {
      // Not supported in offline mode for now
      return Future.value(false);
    }
    return _remote.changePassword(oldPassword, newPassword);
  }

  @override
  Future<bool> requestPasswordReset(String email) {
    if (_env == AppEnv.offline) {
      return Future.value(false);
    }
    return _remote.requestPasswordReset(email);
  }

  @override
  Future<bool> resetPassword(String token, String newPassword) {
    if (_env == AppEnv.offline) {
      return Future.value(false);
    }
    return _remote.resetPassword(token, newPassword);
  }
}
