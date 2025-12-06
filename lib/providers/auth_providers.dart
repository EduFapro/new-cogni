import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/application/login_notifier.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import 'database_provider.dart'; // ✅ FIX

import '../features/auth/data/datasources/evaluator_remote_datasource.dart';
import 'network_provider.dart';

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final dbHelper = ref.watch(databaseProvider);
  final db = await dbHelper.database;
  final network = ref.watch(networkServiceProvider);
  return AuthRepositoryImpl(
    AuthLocalDataSource(db),
    EvaluatorRemoteDataSource(network),
  );
});

final loginProvider = AsyncNotifierProvider.autoDispose<LoginNotifier, bool>(
  () => LoginNotifier(),
);
