import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:segundo_cogni/features/participant/presentation/participant_provider.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/evaluator_providers.dart';
import '../../evaluation/presentation/evaluation_provider.dart';
import '../domain/participant_with_evaluation.dart';

final participantListProvider =
    AsyncNotifierProvider.autoDispose<
      ParticipantListNotifier,
      List<ParticipantWithEvaluation>
    >(ParticipantListNotifier.new);

class ParticipantListNotifier
    extends AsyncNotifier<List<ParticipantWithEvaluation>> {
  @override
  Future<List<ParticipantWithEvaluation>> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      AppLogger.warning(
        'No current user or missing evaluatorId. Skipping fetch.',
      );
      return [];
    }

    AppLogger.info(
      'Fetching participants for evaluatorId=${currentUser.evaluatorId}',
    );

    final participantRepo = ref.watch(participantRepositoryProvider);
    final evaluationRepo = ref.watch(evaluationRepositoryProvider);

    try {
      final participants = await participantRepo.getParticipantsByEvaluatorId(
        currentUser.evaluatorId,
      );
      AppLogger.info('Fetched ${participants.length} participants');

      final evaluations = await evaluationRepo.getEvaluationsByEvaluator(
        currentUser.evaluatorId,
      );
      AppLogger.info('Fetched ${evaluations.length} evaluations');

      final result = participants.map((participant) {
        final match = evaluations.where(
          (e) => e.participantID == participant.participantID,
        );

        final eval = match.isNotEmpty ? match.first : null;

        return ParticipantWithEvaluation(participant, eval);
      }).toList();

      AppLogger.info(
        'Mapped ${result.length} ParticipantWithEvaluation objects',
      );
      return result;
    } catch (e, s) {
      AppLogger.error('Error while building participant list', e, s);
      rethrow;
    }
  }
}
