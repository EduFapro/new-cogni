import '../../../core/constants/database_constants.dart';
import '../../../core/constants/enums/progress_status.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/evaluation_entity.dart';
import '../domain/evaluation_repository.dart';
import 'evaluation_constants.dart';
import 'evaluation_local_datasource.dart';
import 'evaluation_remote_data_source.dart';

import '../../../shared/env/env_helper.dart';
import '../../../core/environment.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationLocalDataSource local;
  final EvaluationRemoteDataSource? remote;

  EvaluationRepositoryImpl({required this.local, this.remote});

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
    AppLogger.db(
      'EvaluationRepositoryImpl.getAllEvaluations → fetched ${list.length} evaluations',
    );
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

  @override
  Future<List<EvaluationEntity>> getEvaluationsByEvaluator(
    int evaluatorId,
  ) async {
    final db = await local.dbHelper.database;
    final maps = await db.query(
      Tables.evaluations,
      where: '${EvaluationFields.evaluatorId} = ?',
      whereArgs: [evaluatorId],
    );

    return maps.map((map) => EvaluationEntity.fromMap(map)).toList();
  }

  @override
  Future<int> setEvaluationStatus(
    int evaluationId,
    EvaluationStatus status,
  ) async {
    AppLogger.db(
      'EvaluationRepositoryImpl.setEvaluationStatus → id=$evaluationId, status=$status',
    );

    // 1. Update local DB (primary operation)
    final db = await local.dbHelper.database;
    final result = await db.update(
      Tables.evaluations,
      {EvaluationFields.status: status.numericValue},
      where: '${EvaluationFields.id} = ?',
      whereArgs: [evaluationId],
    );

    // 2. Sync to backend (fire-and-forget)
    if (remote != null) {
      if (EnvHelper.currentEnv != AppEnv.offline) {
        _syncToBackend(() async {
          final success = await remote!.updateEvaluationStatus(
            evaluationId,
            status.numericValue,
          );
          if (success) {
            AppLogger.info(
              'Evaluation $evaluationId status updated on backend',
            );
          }
        });
      } else {
        AppLogger.info('📴 Offline mode: Skipping Evaluation status sync.');
      }
    }

    return result;
  }

  // Helper method for fire-and-forget backend sync
  void _syncToBackend(Future<void> Function() syncOperation) {
    syncOperation().catchError((error, stackTrace) {
      AppLogger.error(
        'Backend sync failed (continuing locally)',
        error,
        stackTrace,
      );
    });
  }
}
