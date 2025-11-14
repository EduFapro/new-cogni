// lib/seeders/dummy/dummy_evaluator_seed.dart

import 'package:sqflite_common/sqlite_api.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/database_constants.dart';
import '../../features/evaluator/data/evaluator_constants.dart';

Future<void> seedDummyEvaluator(DatabaseExecutor db) async {
  AppLogger.seed('[DUMMY] Seeding dummy evaluator...');

  const dummy = {
    EvaluatorFields.id: 1,
    EvaluatorFields.name: 'Demo',
    EvaluatorFields.surname: 'User',
    EvaluatorFields.email: 'demo@example.com',
    EvaluatorFields.cpf: '03240120010',
    EvaluatorFields.username: 'demo',
    EvaluatorFields.password: '0000',
    EvaluatorFields.specialty: 'Psicologia',
    EvaluatorFields.birthDate: "1998-07-14",
    EvaluatorFields.firstLogin: 1,
    EvaluatorFields.isAdmin: 1,
  };

  await db.insert(
    Tables.evaluators,
    dummy,
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );

  AppLogger.seed('[DUMMY] Dummy evaluator ensured.');
}
