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
  Future<void> clearCurrentUser();
  Future<bool> changePassword(String oldPassword, String newPassword);
  Future<bool> requestPasswordReset(String email);
  Future<bool> resetPassword(String token, String newPassword);
}
