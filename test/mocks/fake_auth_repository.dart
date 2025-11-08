import 'package:segundo_cogni/features/auth/domain/auth_repository.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';

class FakeAuthRepository implements AuthRepository {
  EvaluatorModel? _cachedUser;

  @override
  Future<EvaluatorModel?> login(String email, String password) async {
    if (email == 'john@example.com' && password == 'correctPassword') {
      final user = EvaluatorModel(
        name: 'John',
        surname: 'Doe',
        email: email,
        birthDate: '1990-01-01',
        specialty: 'Psychology',
        cpfOrNif: '12345678900',
        username: 'johndoe',
        password: 'hashed_password',
      );
      _cachedUser = user;
      return user;
    }
    return null;
  }

  @override
  Future<void> saveCurrentUserToDB(EvaluatorModel user) async {
    _cachedUser = user;
  }

  @override
  Future<EvaluatorModel?> getCachedUser() async => _cachedUser;

  @override
  Future<void> clearCurrentUser() async {
    _cachedUser = null;
  }

  @override
  Future<void> clearCurrentUserFromDB() async {
    _cachedUser = null;
  }

  @override
  Future<void> cacheUser(EvaluatorModel user) async {
    _cachedUser = user;
  }

  @override
  Future<void> clearCachedUser() async {
    _cachedUser = null;
  }

  @override
  Future<EvaluatorModel?> fetchCurrentUserOrNull() async => _cachedUser;

  @override
  Future<void> signOut() async {
    _cachedUser = null;
  }
}
