import '../domain/evaluation_entity.dart';
import '../domain/evaluation_repository.dart';
import 'evaluation_local_datasource.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationLocalDataSource local;

  EvaluationRepositoryImpl({required this.local});

  @override
  Future<void> insertEvaluation(EvaluationEntity evaluation) async {
    final db = await local.dbHelper.database;
    await local.insertEvaluation(db, evaluation.toMap());
  }

  @override
  Future<List<EvaluationEntity>> getAllEvaluations() async {
    final db = await local.dbHelper.database;
    return local.getAllEvaluations();
  }

  @override
  Future<EvaluationEntity?> getById(int id) async {
    final db = await local.dbHelper.database;
    return local.getById(db, id);
  }
}
