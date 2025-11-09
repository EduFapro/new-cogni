import 'dart:async';
import 'package:riverpod/riverpod.dart';
import '../../domain/evaluation_entity.dart';
import '../../domain/evaluation_repository.dart';
import '../../presentation/provider.dart';

class EvaluationNotifier extends AsyncNotifier<List<EvaluationEntity>> {
  late final EvaluationRepository _repository;

  @override
  FutureOr<List<EvaluationEntity>> build() async {
    _repository = ref.read(evaluationRepositoryProvider);
    return _repository.getAllEvaluations();
  }

  Future<void> addEvaluation(EvaluationEntity evaluation) async {
    state = const AsyncLoading();
    try {
      await _repository.insertEvaluation(evaluation);
      final updatedList = await _repository.getAllEvaluations();
      state = AsyncData(updatedList);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<EvaluationEntity?> getEvaluationById(int id) async {
    return _repository.getById(id);
  }
}
