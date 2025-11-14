import '../../../core/logger/app_logger.dart';
import '../domain/evaluation_entity.dart';
import '../domain/evaluation_repository.dart';
import 'evaluation_local_datasource.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationLocalDataSource local;

  EvaluationRepositoryImpl({required this.local});

  // ⚠️ This should no longer be used directly outside a transaction
  @override
  Future<void> insertEvaluation(EvaluationEntity evaluation) {
    throw UnimplementedError(
      'Use EvaluationLocalDataSource.insertEvaluation within a transaction instead.',
    );
  }

  @override
  Future<List<EvaluationEntity>> getAllEvaluations() async {
    AppLogger.db('EvaluationRepositoryImpl.getAllEvaluations → fetching');
    final list = await local.getAllEvaluations();
    AppLogger.db('EvaluationRepositoryImpl.getAllEvaluations → fetched ${list.length} evaluations');
    return list;
  }

  @override
  Future<EvaluationEntity?> getById(int id) async {
    AppLogger.db('EvaluationRepositoryImpl.getById → id=$id');
    final db = await local.dbHelper.database;
    final evaluation = await local.getById(db, id);
    if (evaluation == null) {
      AppLogger.warning('EvaluationRepositoryImpl.getById → not found id=$id');
    }
    return evaluation;
  }
}
