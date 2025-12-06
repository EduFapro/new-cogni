import 'package:sqflite_common/sqlite_api.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/database_constants.dart';
import '../../features/evaluator/application/evaluator_secure_service.dart';
import '../../features/evaluator/data/evaluator_model.dart';

Future<void> seedDummyEvaluator(DatabaseExecutor db) async {
  AppLogger.seed('[DUMMY] Seeding dummy evaluator...');

  final evaluator = EvaluatorModel(
    evaluatorId: 1,
    name: 'Demo',
    surname: 'User',
    email: 'demo@example.com',
    birthDate: '1998-07-14',
    specialty: 'Psicologia',
    cpfOrNif: '03240120010',
    username: 'demo',
    password: '0000', // will be hashed
    firstLogin: true,
  );

  final secured = await EvaluatorSecureService.encrypt(evaluator);

  await db.insert(
    Tables.evaluators,
    secured.toEvaluatorTableMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  AppLogger.seed('[DUMMY] ✅ Dummy evaluator inserted (secured).');
}
