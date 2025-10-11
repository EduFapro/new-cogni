// lib/features/auth/application/login_notifier.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../../database_helper.dart';
import '../../auth/data/auth_local_datasource.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/auth_repository.dart';
import '../../../providers.dart'; // where currentUserProvider lives

final loginProvider =
AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<bool> {
  late final AuthRepository _repository;

  /// Just return the initial state — defer heavy logic to actual methods
  @override
  Future<bool> build() async {
    return false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      // Initialize repository only when needed (on demand)
      _repository = await _initAuthRepository();

      final user = await _repository.login(email, password);

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

  /// Initializes AuthRepository directly (no need for a separate provider)
  Future<AuthRepository> _initAuthRepository() async {
    final db = await DatabaseHelper().db;
    final local = AuthLocalDataSource(db);
    return AuthRepositoryImpl(local);
  }
}
