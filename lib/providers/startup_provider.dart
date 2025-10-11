import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/evaluator/application/evaluator_notifier.dart';

enum StartupState { initializing, needsEvaluatorAdmin, ready }

class StartupNotifier extends AsyncNotifier<StartupState> {
  @override
  Future<StartupState> build() async {
    final repository = await ref.watch(evaluatorRepositoryProvider.future);
    final hasAdmin = await repository.hasAnyEvaluatorAdmin();

    return hasAdmin
        ? StartupState.ready
        : StartupState.needsEvaluatorAdmin;
  }

}


final startupProvider =
AsyncNotifierProvider<StartupNotifier, StartupState>(StartupNotifier.new);
