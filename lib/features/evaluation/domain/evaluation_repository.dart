import '../../../core/constants/enums/progress_status.dart';
import 'evaluation_entity.dart';

abstract class EvaluationRepository {
  Future<void> insertEvaluation(EvaluationEntity evaluation);
  Future<List<EvaluationEntity>> getAllEvaluations();
  Future<EvaluationEntity?> getById(int id);
  Future<int> setEvaluationStatus(int evaluationId, EvaluationStatus status);

  Future getEvaluationsByEvaluator(int i) async {}
}
