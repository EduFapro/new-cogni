import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database_helper.dart';
import '../features/auth/application/login_notifier.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import 'database_provider.dart'; // ✅ FIX

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthRepositoryImpl(AuthLocalDataSource(db));
});

final loginProvider = AsyncNotifierProvider.autoDispose<LoginNotifier, bool>(
      () => LoginNotifier(),
);
