import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider, AsyncNotifierProvider, FutureProvider;
import 'package:segundo_cogni/providers/participant_providers.dart';

import '../features/evaluator/data/evaluator_local_datasource.dart';
import '../features/evaluator/data/evaluator_model.dart';
import '../features/evaluator/data/evaluator_remote_datasource.dart';
import '../features/evaluator/data/evaluator_repository_impl.dart';
import '../features/evaluator/domain/evaluator_repository.dart';
import '../features/evaluator/presentation/evaluator_registration_provider.dart';
import 'database_provider.dart';

/// Decides which environment to use and builds repository accordingly
final evaluatorRepositoryProvider = Provider<EvaluatorRepository>((ref) {
  final env = ref.watch(environmentProvider);
  final db = ref.watch(databaseProvider);

  if (env == AppEnv.local) {
    return EvaluatorRepositoryImpl.local(EvaluatorLocalDataSource(db));
  } else {
    return EvaluatorRepositoryImpl.remote(EvaluatorRemoteDataSource());
  }
});

/// Registration Notifier
final evaluatorRegistrationProvider = AsyncNotifierProvider.autoDispose<
    EvaluatorRegistrationNotifier, EvaluatorRegistrationState>(
      () => EvaluatorRegistrationNotifier(),
);

/// Provider to get the current evaluator
final currentEvaluatorProvider = FutureProvider<EvaluatorModel?>((ref) async {
  final db = ref.watch(databaseProvider);
  final ds = EvaluatorLocalDataSource(db);
  return await ds.getFirstEvaluator();
});
