import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/utils/error_parser.dart';
import '../../../providers/auth_providers.dart';

class LoginNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
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
      /// ✅ Await the repository instance from the FutureProvider
      final repo = await ref.read(authRepositoryProvider.future);

      final user = await repo.login(email, password);

      if (user == null) {
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        await repo.saveCurrentUserToDB(user);
        state = const AsyncData(true);
      }

    } catch (e, st) {
      AppLogger.error('Login exception',  e,  st);
      final userFriendly = parseLoginError(e);
      state = AsyncError(userFriendly, st);
    } finally {
      AppLogger.info('Login attempt finished for $email');
    }
  }
}
