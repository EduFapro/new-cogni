import 'evaluator_registration_data.dart';

abstract class EvaluatorRepository {
  Future<void> insertEvaluator(EvaluatorRegistrationData data);
  Future<bool> hasAnyEvaluatorAdmin();
}
