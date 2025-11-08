import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/auth_providers.dart';
import '../../evaluator/data/evaluator_model.dart';
import '../domain/auth_repository.dart';
import '../../../providers/providers.dart';

class LoginNotifier extends AsyncNotifier<bool> {
  late final AuthRepository _repository;

  @override
  Future<bool> build() async {
    _repository = ref.read(authRepositoryProvider);
    return false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    AppLogger.info('Login attempt started for $email');

    if (email.isEmpty || password.isEmpty) {
      state = AsyncError('E-mail e senha são obrigatórios', StackTrace.current);
      return;
    }

    try {
      final user = await _repository.login(email, password);

      if (user == null) {
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        await _repository.saveCurrentUserToDB(user);
        ref.read(currentUserProvider.notifier).setUser(user);
        state = const AsyncData(true);
      }

    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      AppLogger.info('Login attempt finished for $email');
    }
  }
}
