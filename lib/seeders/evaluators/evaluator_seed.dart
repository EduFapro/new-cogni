import '../../core/database_helper.dart';
import '../../core/logger/app_logger.dart';
import '../../features/evaluator/data/evaluator_model.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';
import '../../features/evaluator/domain/evaluator_entity.dart';

Future<void> seedDummyEvaluator() async {
  AppLogger.seed('[EVALUATOR] Checking for existing evaluators...');
  final db = await DatabaseHelper.instance.database;
  final datasource = EvaluatorLocalDataSource(db);

  final exists = await datasource.existsByEmail('dummy@local');
  if (exists) {
    AppLogger.seed('[EVALUATOR] Dummy evaluator already exists.');
    return;
  }


  final dummy = EvaluatorEntity(
    name: 'Dummy',
    surname: 'Evaluator',
    email: 'dummy@local',
    birthDate: '1990-01-01',
    specialty: 'Neuropsychology',
    cpfOrNif: '00000000000',
    username: 'dummy',
    password: '123456',
    firstLogin: false,
  );

  await datasource.insert(EvaluatorModel.fromEntity(dummy));
  AppLogger.seed('[EVALUATOR] ✅ Dummy evaluator created successfully.');
}
