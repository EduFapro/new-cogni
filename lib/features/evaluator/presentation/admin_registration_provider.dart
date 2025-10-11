import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/evaluator_notifier.dart';
import '../domain/evaluator_registration_data.dart';
import '../domain/evaluator_repository.dart';

enum AdminRegistrationState {
  initial,
  loading,
  success,
  error,
}

class AdminRegistrationNotifier extends AsyncNotifier<AdminRegistrationState> {
  late final EvaluatorRepository _repository;

  @override
  Future<AdminRegistrationState> build() async {
    _repository = await ref.watch(evaluatorRepositoryProvider.future);
    return AdminRegistrationState.initial;
  }

  Future<void> registerAdmin(EvaluatorRegistrationData data) async {
    state = const AsyncValue.loading();

    try {
      await _repository.insertEvaluator(data);
      state = const AsyncValue.data(AdminRegistrationState.success);
    } catch (e) {
      print("Error registering admin: $e");
      state = const AsyncValue.data(AdminRegistrationState.error);
    }
  }
}

final adminRegistrationProvider = AsyncNotifierProvider<AdminRegistrationNotifier, AdminRegistrationState>(
  AdminRegistrationNotifier.new,
);
