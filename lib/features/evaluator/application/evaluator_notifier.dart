import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/network_provider.dart';
import '../data/evaluator_local_datasource.dart';
import '../data/evaluator_remote_data_source.dart';
import '../data/evaluator_repository_impl.dart';
import '../domain/evaluator_repository.dart';

class EvaluatorRepositoryNotifier extends AsyncNotifier<EvaluatorRepository> {
  @override
  Future<EvaluatorRepository> build() async {
    try {
      AppLogger.info('EvaluatorRepositoryNotifier initializing...');

      // Local Data Source
      final db = await ProdDatabaseHelper.instance.database;
      final localDataSource = EvaluatorLocalDataSource(db);

      // Remote Data Source
      final networkService = ref.read(networkServiceProvider);
      final remoteDataSource = EvaluatorRemoteDataSource(networkService);

      AppLogger.info('Initializing dual-write EvaluatorRepository');
      return EvaluatorRepositoryImpl(
        local: localDataSource,
        remote: remoteDataSource,
      );
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
