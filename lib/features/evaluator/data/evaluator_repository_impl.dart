import '../../../core/logger/app_logger.dart';
import '../domain/evaluator_repository.dart';
import '../domain/evaluator_registration_data.dart';
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
    AppLogger.info('[REPO] EvaluatorRepositoryImpl running in LOCAL mode');
  }

  EvaluatorRepositoryImpl.remote(this._remote)
      : _local = null,
        _isLocal = false {
    AppLogger.info('[REPO] EvaluatorRepositoryImpl running in REMOTE mode');
  }

  String get _mode => _isLocal ? 'LOCAL' : 'REMOTE';

  Future<List<EvaluatorModel>> getAllEvaluators() async {
    AppLogger.info('[REPO] Fetching all evaluators ($_mode)');
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
      AppLogger.error('[REPO] Error fetching all evaluators ($_mode)', e, s);
      rethrow;
    }
  }

  Future<void> addEvaluator(EvaluatorModel evaluator) async {
    AppLogger.info('[REPO] Adding evaluator ${evaluator.email} ($_mode)');
    try {
      if (_isLocal) {
        await _local!.insert(evaluator);
        AppLogger.db('[REPO] Evaluator inserted into local DB');
      } else {
        await _remote!.createEvaluator(evaluator);
        AppLogger.info('[REPO] Evaluator created remotely');
      }
    } catch (e, s) {
      AppLogger.error('[REPO] Failed to add evaluator', e, s);
      rethrow;
    }
  }

  @override
  Future<void> insertEvaluator(EvaluatorRegistrationData data) async {
    final model = EvaluatorModel.fromDTO(data);
    await _local!.insert(model); // Local insert secures data internally.
  }

  @override
  Future<bool> hasAnyEvaluatorAdmin() async {
    return await _local!.hasAnyEvaluatorAdmin();
  }
}
