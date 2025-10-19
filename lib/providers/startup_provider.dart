import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database_helper.dart';
import '../../core/logger/app_logger.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';

enum StartupState { ready }

final startupProvider =
FutureProvider<StartupState>((ref) async {
  AppLogger.info('[STARTUP] Checking evaluator presence...');
  final db = await DatabaseHelper.instance.database;
  final evaluatorDS = EvaluatorLocalDataSource(db);

  final evaluators = await evaluatorDS.getAll();

  if (evaluators.isEmpty) {
    AppLogger.warning(
        '[STARTUP] No evaluators found — seeder might not have run yet');
  } else {
    AppLogger.info(
        '[STARTUP] Found ${evaluators.length} evaluator(s), proceeding to login');
  }

  return StartupState.ready;
});
