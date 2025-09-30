import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../app/database_helper.dart';
import '../../auth/data/auth_local_datasource.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/auth_repository.dart';

final dbProvider = FutureProvider<Database>((ref) async {
  final dbHelper = DatabaseHelper();
  return dbHelper.db;
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final db = await ref.watch(dbProvider.future);
  final localDataSource = AuthLocalDataSource(db);
  return AuthRepositoryImpl(localDataSource);
});

final loginProvider =
AsyncNotifierProvider<LoginNotifier, bool>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<bool> {
  late final AuthRepository _repository;

  @override
  Future<bool> build() async {
    _repository = await ref.watch(authRepositoryProvider.future);
    return false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final success = await _repository.login(email, password);
      if (!success) {
        state = AsyncError('Credenciais inválidas', StackTrace.current);
      } else {
        state = const AsyncData(true);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
