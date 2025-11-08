import '../../evaluator/data/evaluator_model.dart';

abstract class AuthRepository {
  Future<EvaluatorModel?> login(String email, String password);
  Future<void> signOut();
  Future<void> cacheUser(EvaluatorModel user);
  Future<void> clearCachedUser();
  Future<EvaluatorModel?> getCachedUser();
  Future<EvaluatorModel?> fetchCurrentUserOrNull();
  Future<void> saveCurrentUserToDB(EvaluatorModel user);
  Future<void> clearCurrentUserFromDB();
}
