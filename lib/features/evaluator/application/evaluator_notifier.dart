import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_database.dart';
import '../../../providers.dart';
import '../data/evaluator_local_datasource.dart';
import '../data/evaluator_remote_datasource.dart';
import '../data/evaluator_repository_impl.dart';
import '../domain/evaluator_repository.dart';

class EvaluatorRepositoryNotifier extends AsyncNotifier<EvaluatorRepository> {
  @override
  Future<EvaluatorRepository> build() async {
    try {
      final env = ref.watch(environmentProvider);

      if (env == AppEnv.local) {
        final db = await AppDatabase.instance.db;
        return EvaluatorRepositoryImpl.local(EvaluatorLocalDataSource(db));
      } else {
        return EvaluatorRepositoryImpl.remote(EvaluatorRemoteDataSource());
      }
    } catch (e, st) {
      print('DB init error: $e');
      rethrow;
    }
  }
}


final evaluatorRepositoryProvider =
AsyncNotifierProvider<EvaluatorRepositoryNotifier, EvaluatorRepository>(
    EvaluatorRepositoryNotifier.new);
