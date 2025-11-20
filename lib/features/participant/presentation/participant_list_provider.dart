import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:segundo_cogni/features/participant/presentation/participant_provider.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/evaluator_providers.dart';
import '../../evaluation/presentation/evaluation_provider.dart';
import '../domain/participant_entity.dart';
import '../domain/participant_with_evaluation.dart';

final participantListProvider = AsyncNotifierProvider.autoDispose<
    ParticipantListNotifier,
    List<ParticipantWithEvaluation>
>(ParticipantListNotifier.new);

class ParticipantListNotifier extends AsyncNotifier<List<ParticipantWithEvaluation>> {
  @override
  Future<List<ParticipantWithEvaluation>> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null || currentUser.evaluatorId == null) {
      AppLogger.info('No current user, returning empty list');
      return [];
    }

    final participantRepo = ref.watch(participantRepositoryProvider);
    final evaluationRepo = ref.watch(evaluationRepositoryProvider);

    final participants = await participantRepo.getParticipantsByEvaluatorId(currentUser.evaluatorId!);
    final evaluations = await evaluationRepo.getEvaluationsByEvaluator(currentUser.evaluatorId!);

    return participants.map((participant) {
      final eval = evaluations.firstWhere(
            (e) => e.participantID == participant.participantID,
        orElse: () => null,
      );
      return ParticipantWithEvaluation(participant, eval);
    }).toList();
  }
}
