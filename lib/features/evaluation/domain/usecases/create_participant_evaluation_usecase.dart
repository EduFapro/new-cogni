import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/constants/enums/progress_status.dart';

import '../../../participant/domain/participant_entity.dart';
import '../../../participant/data/participant_local_datasource.dart';
import '../../../participant/data/participant_remote_data_source.dart';

import '../../../evaluation/data/evaluation_local_datasource.dart';
import '../../../evaluation/data/evaluation_remote_data_source.dart';
import '../../../evaluation/domain/evaluation_entity.dart';

import '../../../module/domain/module_repository.dart';
import '../../../module_instance/domain/module_instance_entity.dart';
import '../../../module_instance/domain/module_instance_repository.dart';

import '../../../task/data/task_local_datasource.dart';
import '../../../task_instance/domain/task_instance_entity.dart';
import '../../../task_instance/domain/task_instance_repository.dart';

class CreateParticipantEvaluationUseCase {
  final ParticipantLocalDataSource participantDataSource;
  final ParticipantRemoteDataSource? participantRemoteDataSource;
  final EvaluationLocalDataSource evaluationDataSource;
  final EvaluationRemoteDataSource? evaluationRemoteDataSource;
  final ModuleRepository moduleRepository;
  final ModuleInstanceRepository moduleInstanceRepository;
  final TaskLocalDataSource taskDataSource;
  final TaskInstanceRepository taskInstanceRepository;
  final Database db;

  CreateParticipantEvaluationUseCase({
    required this.participantDataSource,
    this.participantRemoteDataSource,
    required this.evaluationDataSource,
    this.evaluationRemoteDataSource,
    required this.moduleRepository,
    required this.moduleInstanceRepository,
    required this.taskDataSource,
    required this.taskInstanceRepository,
    required this.db,
  });

  Future<ParticipantEntity> execute({
    required ParticipantEntity participant,
    required int evaluatorId,
    required List<int> selectedModuleIds,
    int language = 1,
  }) async {
    AppLogger.info(
      '[USECASE] Starting participant creation: ${participant.name} (selectedModules=$selectedModuleIds)',
    );

    late final int participantId;
    late final int evaluationId;

    try {
      // 🔁 FIRST TRANSACTION: Insert participant and evaluation
      await db.transaction((txn) async {
        final insertedParticipantId = await participantDataSource
            .insertParticipant(txn, participant.toMap());

        if (insertedParticipantId == null) {
          AppLogger.error(
            '[USECASE] ❌ Failed to insert participant (null returned)',
          );
          throw Exception('Participant insertion failed');
        }
        participantId = insertedParticipantId;
        AppLogger.db('[USECASE] ✅ Participant inserted: id=$participantId');

        final evaluation = EvaluationEntity(
          evaluatorID: evaluatorId,
          participantID: participantId,
          status: EvaluationStatus.pending,
          language: language,
        );

        final insertedEvaluationId = await evaluationDataSource
            .insertEvaluation(txn, evaluation.toMap());

        if (insertedEvaluationId == null) {
          AppLogger.error(
            '[USECASE] ❌ Failed to insert evaluation (null returned)',
          );
          throw Exception('Evaluation insertion failed');
        }
        evaluationId = insertedEvaluationId;
        AppLogger.db('[USECASE] ✅ Evaluation inserted: id=$evaluationId');
      });

      // 🔁 SECOND TRANSACTION: Fetch modules and create module/task instances
      final allModules = await moduleRepository.getAllModules().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.error('[USECASE] ❌ Timeout while fetching modules');
          throw Exception('Timeout fetching modules');
        },
      );
      AppLogger.info('[USECASE] 🧩 Fetched ${allModules.length} modules');

      final modulesToUse = selectedModuleIds.isEmpty
          ? allModules
          : allModules
                .where(
                  (m) =>
                      m.moduleID != null &&
                      selectedModuleIds.contains(m.moduleID),
                )
                .toList();

      AppLogger.info('[USECASE] 📦 Using ${modulesToUse.length} modules');

      for (final module in modulesToUse) {
        if (module.moduleID == null) continue;

        final moduleInstance = ModuleInstanceEntity(
          moduleId: module.moduleID!,
          status: ModuleStatus.pending,
          evaluationId: evaluationId,
        );

        final moduleInstanceCreated = await moduleInstanceRepository
            .createModuleInstance(moduleInstance);
        final moduleInstanceId = moduleInstanceCreated?.id;

        if (moduleInstanceId == null) {
          AppLogger.error(
            '[USECASE] ❌ Failed to create ModuleInstance for moduleId=${module.moduleID}',
          );
          continue;
        }

        final tasks = await taskDataSource.getTasksByModuleId(module.moduleID!);
        AppLogger.info(
          '[USECASE] 🔧 Found ${tasks.length} tasks for moduleId=${module.moduleID}',
        );

        for (final task in tasks) {
          if (task.taskID == null) continue;

          final taskInstance = TaskInstanceEntity(
            taskId: task.taskID!,
            moduleInstanceId: moduleInstanceId,
            status: TaskStatus.pending,
          );

          final taskInstanceId = await taskInstanceRepository.insert(
            taskInstance,
          );
          AppLogger.db(
            '[USECASE] ✅ TaskInstance inserted: id=$taskInstanceId (taskId=${task.taskID})',
          );
        }
      }

      final createdParticipant = participant.copyWith(
        participantID: participantId,
      );
      AppLogger.info(
        '[USECASE] ✅ Participant + Evaluation + Modules + Tasks created successfully',
      );

      // 🔁 SYNC TO BACKEND (Fire-and-forget)
      _syncToBackend(
        participant: createdParticipant,
        evaluatorId: evaluatorId,
        evaluationId: evaluationId,
        language: language,
      );

      return createdParticipant;
    } catch (e, s) {
      AppLogger.error(
        '[USECASE] ❌ Creation failed. DB may be partially written.',
        e,
        s,
      );
      rethrow;
    }
  }

  void _syncToBackend({
    required ParticipantEntity participant,
    required int evaluatorId,
    required int evaluationId,
    required int language,
  }) {
    if (participantRemoteDataSource == null ||
        evaluationRemoteDataSource == null) {
      return;
    }

    Future.microtask(() async {
      try {
        // 1. Sync Participant
        final backendParticipantId = await participantRemoteDataSource!
            .createParticipant(participant, evaluatorId);

        if (backendParticipantId != null) {
          AppLogger.info(
            '[USECASE] Participant synced to backend ID: $backendParticipantId',
          );

          // 2. Sync Evaluation
          // NOTE: Backend now automatically creates Evaluation + Modules + Tasks
          // when a Participant is created. We do NOT need to create it manually here.
          // If we did, we would create a duplicate.
          AppLogger.info(
            '[USECASE] Participant synced. Backend auto-creates Evaluation/Modules.',
          );
        }
      } catch (e, s) {
        AppLogger.error('[USECASE] Backend sync failed', e, s);
      }
    });
  }
}
