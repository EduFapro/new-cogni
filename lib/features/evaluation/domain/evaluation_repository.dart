import 'evaluation_entity.dart';

abstract class EvaluationRepository {
  Future<void> insertEvaluation(EvaluationEntity evaluation);
  Future<List<EvaluationEntity>> getAllEvaluations();
  Future<EvaluationEntity?> getById(int id);
}
