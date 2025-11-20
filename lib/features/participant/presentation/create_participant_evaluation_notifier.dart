import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/logger/app_logger.dart';
import '../../../providers/participant_providers.dart';

import '../../evaluation/data/evaluation_local_datasource.dart';
import '../../evaluation/domain/usecases/create_participant_evaluation_usecase.dart';

import '../../module/data/module_local_datasource.dart';
import '../../module/data/module_repository_impl.dart'; // ✅ Added
import '../../task/data/task_local_datasource.dart';

import '../../module_instance/data/module_instance_local_datasource.dart';
import '../../module_instance/data/module_instance_repository_impl.dart';

import '../../task_instance/data/task_instance_local_datasource.dart';
import '../../task_instance/data/task_instance_repository_impl.dart';

import '../data/participant_local_datasource.dart';
import '../domain/participant_entity.dart';

class CreateParticipantEvaluationNotifier extends AsyncNotifier<ParticipantEntity?> {
  late final CreateParticipantEvaluationUseCase _useCase;

  @override
  FutureOr<ParticipantEntity?> build() async {
    final dbHelper = ref.read(participantDbHelperProvider);
    final db = await dbHelper.database;

    AppLogger.info('[PROVIDER] Initializing CreateParticipantEvaluationUseCase');

    _useCase = CreateParticipantEvaluationUseCase(
      participantDataSource: ParticipantLocalDataSource(dbHelper: dbHelper),
      evaluationDataSource: EvaluationLocalDataSource(dbHelper: dbHelper),
      moduleRepository: ModuleRepositoryImpl(
        local: ModuleLocalDataSource(dbHelper: dbHelper),
        taskLocal: TaskLocalDataSource(dbHelper: dbHelper),
      ), // ✅ ADD THIS
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
    required List<int> selectedModuleIds,
  }) async {
    state = const AsyncLoading();
    AppLogger.info(
      '[PROVIDER] Creating participant with evaluation for evaluatorId=$evaluatorId '
          'selectedModules=$selectedModuleIds',
    );

    try {
      final created = await _useCase.execute(
        participant: participant,
        evaluatorId: evaluatorId,
        selectedModuleIds: selectedModuleIds,
      );

      AppLogger.info(
        '[PROVIDER] ✅ Participant + Evaluation created (participantId=${created.participantID})',
      );
      state = AsyncData(created);
    } catch (e, s) {
      AppLogger.error(
        '[PROVIDER] ❌ Failed to create participant with evaluation',
        e,
        s,
      );
      state = AsyncError(e, s);
    }
  }
}
