import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/logger/app_logger.dart';
import '../application/evaluator_notifier.dart';
import '../domain/evaluator_registration_data.dart';
import '../domain/evaluator_repository.dart';

enum EvaluatorRegistrationState { initial, loading, success, error }

class EvaluatorRegistrationNotifier
    extends AsyncNotifier<EvaluatorRegistrationState> {
  late final EvaluatorRepository _repository;

  @override
  Future<EvaluatorRegistrationState> build() async {
    _repository = await ref.watch(evaluatorRepositoryProvider.future);
    AppLogger.info('EvaluatorRegistrationNotifier initialized');
    return EvaluatorRegistrationState.initial;
  }

  Future<void> registerEvaluator(EvaluatorRegistrationData data) async {
    AppLogger.info('Starting evaluator registration for ${data.email}');
    state = const AsyncValue.loading();

    try {
      await _repository.insertEvaluator(data);
      AppLogger.info('Evaluator ${data.email} registered successfully');
      state = const AsyncValue.data(EvaluatorRegistrationState.success);
    } catch (e, s) {
      AppLogger.error('Error registering evaluator ${data.email}', e, s);
      state = const AsyncValue.data(EvaluatorRegistrationState.error);
    }
  }
}

final evaluatorRegistrationProvider =
AsyncNotifierProvider<EvaluatorRegistrationNotifier,
    EvaluatorRegistrationState>(
  EvaluatorRegistrationNotifier.new,
);
