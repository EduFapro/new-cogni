import 'package:segundo_cogni/features/evaluator/domain/evaluator_registration_data.dart';

import '../../../core/logger/app_logger.dart';
import '../domain/evaluator_repository.dart';
import 'evaluator_local_datasource.dart';
import 'evaluator_remote_datasource.dart';
import 'evaluator_model.dart';

class EvaluatorRepositoryImpl implements EvaluatorRepository {
  final EvaluatorLocalDataSource? _local;
  final EvaluatorRemoteDataSource? _remote;
  final bool _isLocal;

  EvaluatorRepositoryImpl.local(this._local)
      : _remote = null,
        _isLocal = true {
    AppLogger.info('EvaluatorRepositoryImpl running in LOCAL mode');
  }

  EvaluatorRepositoryImpl.remote(this._remote)
      : _local = null,
        _isLocal = false {
    AppLogger.info('EvaluatorRepositoryImpl running in REMOTE mode');
  }

  @override
  Future<List<EvaluatorModel>> getAllEvaluators() async {
    AppLogger.info('Fetching all evaluators ($_mode)');
    try {
      if (_isLocal) {
        final list = await _local!.getAll();
        AppLogger.db('Fetched ${list.length} evaluators from local DB');
        return list;
      } else {
        final list = await _remote!.fetchAllEvaluators();
        AppLogger.info('Fetched ${list.length} evaluators from API');
        return list;
      }
    } catch (e, s) {
      AppLogger.error('Error fetching all evaluators ($_mode)', e, s);
      rethrow;
    }
  }

  @override
  Future<void> addEvaluator(EvaluatorModel evaluator) async {
    AppLogger.info('Adding evaluator ${evaluator.email} ($_mode)');
    try {
      if (_isLocal) {
        await _local!.insert(evaluator);
        AppLogger.db('Evaluator inserted into local DB: ${evaluator.email}');
      } else {
        await _remote!.createEvaluator(evaluator);
        AppLogger.info('Evaluator created remotely: ${evaluator.email}');
      }
    } catch (e, s) {
      AppLogger.error('Failed to add evaluator ${evaluator.email}', e, s);
      rethrow;
    }
  }

  String get _mode => _isLocal ? 'LOCAL' : 'REMOTE';

  @override
  Future<void> insertEvaluator(EvaluatorRegistrationData data) async {
    final model = EvaluatorModel.fromDTO(data);
    await _local!.insert(model);
  }

  @override
  Future<bool> hasAnyEvaluatorAdmin() async {
    return await _local!.hasAnyEvaluatorAdmin();
  }
}
