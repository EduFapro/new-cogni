import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/evaluator_notifier.dart';
import '../domain/evaluator_registration_data.dart';
import '../domain/evaluator_repository.dart';

enum EvaluatorRegistrationState {
  initial,
  loading,
  success,
  error,
}

class EvaluatorRegistrationNotifier extends AsyncNotifier<EvaluatorRegistrationState> {
  late final EvaluatorRepository _repository;

  @override
  Future<EvaluatorRegistrationState> build() async {
    _repository = await ref.watch(evaluatorRepositoryProvider.future);
    return EvaluatorRegistrationState.initial;
  }

  Future<void> registerEvaluator(EvaluatorRegistrationData data) async {
    state = const AsyncValue.loading();

    try {
      await _repository.insertEvaluator(data);
      state = const AsyncValue.data(EvaluatorRegistrationState.success);
    } catch (e) {
      print("Error registering evaluator: $e");
      state = const AsyncValue.data(EvaluatorRegistrationState.error);
    }
  }
}

final evaluatorRegistrationProvider = AsyncNotifierProvider<EvaluatorRegistrationNotifier, EvaluatorRegistrationState>(
  EvaluatorRegistrationNotifier.new,
);
