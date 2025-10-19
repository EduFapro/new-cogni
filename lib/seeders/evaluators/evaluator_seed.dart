import 'package:sqflite_common/sqlite_api.dart';
import '../../core/logger/app_logger.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';
import '../../features/evaluator/data/evaluator_model.dart';
import '../../features/evaluator/domain/evaluator_entity.dart';

Future<void> seedDummyEvaluator(Database db) async {
  AppLogger.seed('[EVALUATOR] Seeding dummy evaluator...');

  final datasource = EvaluatorLocalDataSource(db);

  final dummy = EvaluatorEntity(
    name: 'Dummy',
    surname: 'Evaluator',
    email: 'dummy@local',
    birthDate: DateTime(1990, 1, 1).toIso8601String(),
    specialty: 'Testing',
    cpfOrNif: '00000000000',
    username: 'dummy',
    password: '123456',
    isAdmin: false,
  );

  final exists = await datasource.existsByEmail(dummy.email);

  if (!exists) {
    await datasource.insert(EvaluatorModel.fromEntity(dummy));
    AppLogger.seed('[EVALUATOR] Dummy evaluator created ✅');
  } else {
    AppLogger.seed('[EVALUATOR] Dummy evaluator already exists');
  }
}
