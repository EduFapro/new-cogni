import '../domain/evaluator_registration_data.dart';
import '../domain/evaluator_repository.dart';
import 'evaluator_local_datasource.dart';
import 'evaluator_model.dart';
import 'evaluator_remote_datasource.dart';

class EvaluatorRepositoryImpl implements EvaluatorRepository {
  final EvaluatorLocalDataSource? _local;
  final EvaluatorRemoteDataSource? _remote;

  EvaluatorRepositoryImpl.local(this._local) : _remote = null;
  EvaluatorRepositoryImpl.remote(this._remote) : _local = null;

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
