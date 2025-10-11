import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  EvaluatorModel? _cachedUser;

  AuthRepositoryImpl(this._local);

  /// Attempts to log in by verifying email and password
  @override
  Future<EvaluatorModel?> login(String email, String password) async {
    final admin = await _local.getAdminByEmail(email);

    if (admin != null && admin.password == password) {
      await cacheUser(admin);
      return admin;
    }

    return null;
  }

  /// Stores the current user in memory and database for persistence
  @override
  Future<void> cacheUser(EvaluatorModel user) async {
    _cachedUser = user;
    await _local.saveCurrentUser(user); // <- implement in AuthLocalDataSource
  }

  /// Clears cached user from memory and database
  @override
  Future<void> clearCachedUser() async {
    _cachedUser = null;
    await _local.clearCurrentUser(); // <- implement in AuthLocalDataSource
  }

  /// Returns user cached in memory (if any)
  @override
  Future<EvaluatorModel?> getCachedUser() async {
    return _cachedUser;
  }

  /// Attempts to retrieve cached user from memory or database
  @override
  Future<EvaluatorModel?> fetchCurrentUserOrNull() async {
    if (_cachedUser != null) return _cachedUser;

    final user = await _local.getCachedUser(); // <- implement in AuthLocalDataSource
    _cachedUser = user;
    return user;
  }

  /// Signs out and clears all cached user data
  @override
  Future<void> signOut() async {
    await clearCachedUser();
  }
}
