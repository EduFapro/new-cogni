// lib/features/auth/application/login_notifier.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../../database_helper.dart';
import '../../auth/data/auth_local_datasource.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/auth_repository.dart';
import '../../../providers.dart'; // where currentUserProvider lives

// --- DB Provider ---
final dbProvider = FutureProvider<Database>((ref) async {
  final dbHelper = DatabaseHelper();
  return dbHelper.db;
});

// --- Auth Repository Provider ---
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final db = await ref.watch(dbProvider.future);
  final localDataSource = AuthLocalDataSource(db);
  return AuthRepositoryImpl(localDataSource);
});

// --- Login Provider ---
final loginProvider =
AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<bool> {
  late final AuthRepository _repository;

  @override
  Future<bool> build() async {
    _repository = await ref.watch(authRepositoryProvider.future);
    return false; // initial state
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final user = await _repository.login(email, password);

      if (user == null) {
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        // store current user in the global provider
        ref.read(currentUserProvider.notifier).setUser(user);
        state = const AsyncData(true);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
