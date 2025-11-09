import 'dart:async';
import 'package:riverpod/riverpod.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/evaluation_entity.dart';
import '../../domain/evaluation_repository.dart';
import '../../presentation/provider.dart';

class EvaluationNotifier extends AsyncNotifier<List<EvaluationEntity>> {
  late final EvaluationRepository _repository;

  @override
  FutureOr<List<EvaluationEntity>> build() async {
    _repository = ref.read(evaluationRepositoryProvider);
    AppLogger.info('EvaluationNotifier.build → loading evaluations');
    try {
      final evaluations = await _repository.getAllEvaluations();
      AppLogger.info('EvaluationNotifier.build → loaded ${evaluations.length} evaluations');
      return evaluations;
    } catch (e, s) {
      AppLogger.error('EvaluationNotifier.build → failed to load evaluations', e, s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    AppLogger.info('EvaluationNotifier.refresh → reloading evaluations');
    state = const AsyncLoading();
    try {
      final evaluations = await _repository.getAllEvaluations();
      AppLogger.info('EvaluationNotifier.refresh → loaded ${evaluations.length} evaluations');
      state = AsyncData(evaluations);
    } catch (e, s) {
      AppLogger.error('EvaluationNotifier.refresh → error', e, s);
      state = AsyncError(e, s);
    }
  }

  Future<void> addEvaluation(EvaluationEntity evaluation) async {
    AppLogger.info(
      'EvaluationNotifier.addEvaluation → participantId=${evaluation.participantID}, evaluatorId=${evaluation.evaluatorID}',
    );
    state = const AsyncLoading();
    try {
      await _repository.insertEvaluation(evaluation);
      final updated = await _repository.getAllEvaluations();
      AppLogger.info('EvaluationNotifier.addEvaluation → now ${updated.length} evaluations');
      state = AsyncData(updated);
    } catch (e, s) {
      AppLogger.error('EvaluationNotifier.addEvaluation → error', e, s);
      state = AsyncError(e, s);
    }
  }

  Future<EvaluationEntity?> getEvaluationById(int id) async {
    AppLogger.info('EvaluationNotifier.getEvaluationById → id=$id');
    try {
      final evaluation = await _repository.getById(id);
      if (evaluation == null) {
        AppLogger.warning('EvaluationNotifier.getEvaluationById → no evaluation found for id=$id');
      }
      return evaluation;
    } catch (e, s) {
      AppLogger.error('EvaluationNotifier.getEvaluationById → error', e, s);
      rethrow;
    }
  }
}
