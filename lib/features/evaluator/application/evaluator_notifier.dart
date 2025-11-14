import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../../../core/environment.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/providers.dart';
import '../data/evaluator_local_datasource.dart';
import '../data/evaluator_remote_datasource.dart';
import '../data/evaluator_repository_impl.dart';
import '../domain/evaluator_repository.dart';

class EvaluatorRepositoryNotifier extends AsyncNotifier<EvaluatorRepository> {
  @override
  Future<EvaluatorRepository> build() async {
    try {
      final env = ref.watch(environmentProvider);
      AppLogger.info('EvaluatorRepositoryNotifier started (env=$env)');

      if (env == AppEnv.local) {
        final db = await ProdDatabaseHelper.instance.database;
        AppLogger.db('Initializing local EvaluatorRepository...');
        return EvaluatorRepositoryImpl.local(EvaluatorLocalDataSource(db));
      } else {
        AppLogger.info('Initializing remote EvaluatorRepository...');
        return EvaluatorRepositoryImpl.remote(EvaluatorRemoteDataSource());
      }
    } catch (e, s) {
      AppLogger.error('EvaluatorRepository initialization failed', e, s);
      rethrow;
    }
  }
}

final evaluatorRepositoryProvider =
AsyncNotifierProvider<EvaluatorRepositoryNotifier, EvaluatorRepository>(
  EvaluatorRepositoryNotifier.new,
);
