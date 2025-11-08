import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._local);

  @override
  Future<EvaluatorModel?> login(String email, String password) {
    return _local.getEvaluatorByEmail(email);
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
