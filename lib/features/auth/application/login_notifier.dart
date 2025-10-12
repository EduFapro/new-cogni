import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/providers.dart';
import '../data/auth_local_datasource.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

final loginProvider =
AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<bool> {
  AuthRepository? _repository;

  @override
  Future<bool> build() async => false;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    AppLogger.info('Login attempt started for $email');

    if (email.isEmpty || password.isEmpty) {
      AppLogger.warning('Validation failed: empty email or password');
      state = AsyncError('E-mail e senha são obrigatórios', StackTrace.current);
      return;
    }

    try {
      _repository ??= await _initAuthRepository();
      final user = await _repository!.login(email, password);

      if (user == null) {
        AppLogger.warning('Invalid credentials for $email');
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        AppLogger.info('Login successful for ${user.email}');
        ref.read(currentUserProvider.notifier).setUser(user);
        state = const AsyncData(true);
      }
    } catch (e, st) {
      AppLogger.error('Login failed for $email', e, st);
      state = AsyncError(e, st);
    } finally {
      AppLogger.info('Login attempt finished for $email');
    }
  }

  Future<AuthRepository> _initAuthRepository() async {
    final db = await DatabaseHelper.instance.database;
    AppLogger.db('AuthRepository initialized with DB instance');
    final local = AuthLocalDataSource(db);
    return AuthRepositoryImpl(local);
  }
}
