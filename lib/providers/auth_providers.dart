import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/application/login_notifier.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import 'database_provider.dart'; // ✅ FIX

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final dbHelper = ref.watch(databaseProvider);
  final db = await dbHelper.database;
  return AuthRepositoryImpl(AuthLocalDataSource(db));
});


final loginProvider = AsyncNotifierProvider.autoDispose<LoginNotifier, bool>(
      () => LoginNotifier(),
);
