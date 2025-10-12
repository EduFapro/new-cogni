import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../database_helper.dart';
import '../../auth/data/auth_local_datasource.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/auth_repository.dart';
import '../../../providers.dart';

final loginProvider =
AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<bool> {
  AuthRepository? _repository;


  @override
  Future<bool> build() async {
    return false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      _repository ??= await _initAuthRepository();

      final user = await _repository!.login(email, password);

      if (user == null) {
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        ref.read(currentUserProvider.notifier).setUser(user);
        state = const AsyncData(true);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<AuthRepository> _initAuthRepository() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    final local = AuthLocalDataSource(db);
    return AuthRepositoryImpl(local);
  }

}
