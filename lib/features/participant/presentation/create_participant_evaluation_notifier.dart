import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/logger/app_logger.dart';
import '../../../core/constants/enums/person_enums.dart';
import '../../evaluation/data/evaluation_local_datasource.dart';
import '../../evaluation/domain/usecases/create_participant_evaluation_usecase.dart';
import '../../module/data/module_local_datasource.dart';
import '../../module_instance/data/module_instance_local_datasource.dart';
import '../../module_instance/data/module_instance_repository_impl.dart';
import '../../task/data/task_local_datasource.dart';
import '../../task_instance/data/task_instance_local_datasource.dart';
import '../../task_instance/data/task_instance_repository_impl.dart';
import '../data/participant_local_datasource.dart';
import '../domain/participant_entity.dart';

import '../../../providers/participant_providers.dart';

class CreateParticipantEvaluationNotifier
    extends AsyncNotifier<ParticipantEntity?> {
  late final CreateParticipantEvaluationUseCase _useCase;

  @override
  FutureOr<ParticipantEntity?> build() async {
    final dbHelper = ref.read(participantDbHelperProvider);
    final db = await dbHelper.database;

    _useCase = CreateParticipantEvaluationUseCase(
      participantDataSource: ParticipantLocalDataSource(dbHelper: dbHelper),
      evaluationDataSource: EvaluationLocalDataSource(dbHelper: dbHelper),
      moduleDataSource: ModuleLocalDataSource(dbHelper: dbHelper),
      moduleInstanceRepository: ModuleInstanceRepositoryImpl(
        localDataSource: ModuleInstanceLocalDataSource(dbHelper: dbHelper),
      ),
      taskDataSource: TaskLocalDataSource(dbHelper: dbHelper),
      taskInstanceRepository: TaskInstanceRepositoryImpl(
        localDataSource: TaskInstanceLocalDataSource(dbHelper: dbHelper),
      ),
      db: db,
    );

    return null;
  }

  Future<void> createParticipantWithEvaluation({
    required ParticipantEntity participant,
    required int evaluatorId,
  }) async {
    state = const AsyncLoading();
    AppLogger.info('[PROVIDER] Creating participant for evaluator=$evaluatorId');

    try {
      final created = await _useCase.execute(
        participant: participant,
        evaluatorId: evaluatorId,
      );

      AppLogger.info('[PROVIDER] ✅ Participant + Evaluation created successfully');
      state = AsyncData(created);
    } catch (e, s) {
      AppLogger.error('[PROVIDER] ❌ Failed to create participant', e, s);
      state = AsyncError(e, s);
    }
  }

}
