import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/logger/app_logger.dart';
import '../../../providers/evaluator_providers.dart';
import '../domain/participant_entity.dart';
import 'participant_provider.dart';

final participantListProvider =
    AsyncNotifierProvider.autoDispose<
      ParticipantListNotifier,
      List<ParticipantEntity>
    >(ParticipantListNotifier.new);

class ParticipantListNotifier
    extends AutoDisposeAsyncNotifier<List<ParticipantEntity>> {
  @override
  Future<List<ParticipantEntity>> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null || currentUser.evaluatorId == null) {
      AppLogger.info(
        'ParticipantListNotifier: No current user, returning empty list',
      );
      return [];
    }

    AppLogger.info(
      'ParticipantListNotifier: Fetching participants for evaluator ${currentUser.evaluatorId}',
    );
    final repository = ref.watch(participantRepositoryProvider);
    return repository.getParticipantsByEvaluatorId(currentUser.evaluatorId!);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
