import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/constants/enums/progress_status.dart';

import '../../../participant/domain/participant_entity.dart';
import '../../../participant/data/participant_local_datasource.dart';

import '../../../evaluation/data/evaluation_local_datasource.dart';
import '../../../evaluation/domain/evaluation_entity.dart';

import '../../../module/data/module_local_datasource.dart';

import '../../../module_instance/domain/module_instance_entity.dart';
import '../../../module_instance/domain/module_instance_repository.dart';

import '../../../task/data/task_local_datasource.dart';

import '../../../task_instance/domain/task_instance_entity.dart';
import '../../../task_instance/domain/task_instance_repository.dart';

class CreateParticipantEvaluationUseCase {
  final ParticipantLocalDataSource participantDataSource;
  final EvaluationLocalDataSource evaluationDataSource;
  final ModuleLocalDataSource moduleDataSource;
  final ModuleInstanceRepository moduleInstanceRepository;
  final TaskLocalDataSource taskDataSource;
  final TaskInstanceRepository taskInstanceRepository;
  final Database db;

  CreateParticipantEvaluationUseCase({
    required this.participantDataSource,
    required this.evaluationDataSource,
    required this.moduleDataSource,
    required this.moduleInstanceRepository,
    required this.taskDataSource,
    required this.taskInstanceRepository,
    required this.db,
  });

  /// Creates:
  /// - Participant
  /// - Evaluation
  /// - ModuleInstances only for [selectedModuleIds] (or all if empty)
  /// - TaskInstances for tasks in those modules
  Future<ParticipantEntity> execute({
    required ParticipantEntity participant,
    required int evaluatorId,
    required List<int> selectedModuleIds,
    int language = 1,
  }) async {
    AppLogger.info(
      '[USECASE] Starting participant creation: ${participant.name} '
          '(selectedModules=$selectedModuleIds)',
    );

    late final ParticipantEntity createdParticipant;

    await db.transaction((txn) async {
      // 1) Participant
      final participantId =
      await participantDataSource.insertParticipant(txn, participant.toMap());
      AppLogger.db('[USECASE] Participant inserted: id=$participantId');

      // 2) Evaluation
      final evaluation = EvaluationEntity(
        evaluatorID: evaluatorId,
        participantID: participantId!,
        status: EvaluationStatus.pending,
        language: language,
      );

      final evaluationId =
      await evaluationDataSource.insertEvaluation(txn, evaluation.toMap());
      AppLogger.db('[USECASE] Evaluation created: id=$evaluationId');

      // 3) Decide which modules to use
      final allModules = await moduleDataSource.getAllModules();
      final modulesToUse = selectedModuleIds.isEmpty
          ? allModules
          : allModules
          .where((m) =>
      m.moduleID != null &&
          selectedModuleIds.contains(m.moduleID))
          .toList();

      AppLogger.info(
        '[USECASE] Using ${modulesToUse.length} module(s) for evaluation '
            '(allModules=${allModules.length})',
      );

      // 4) Create module instances + task instances
      for (final module in modulesToUse) {
        if (module.moduleID == null) continue;

        final moduleInstance = ModuleInstanceEntity(
          moduleId: module.moduleID!,
          evaluationId: evaluationId!,
          status: ModuleStatus.pending,
        );

        final moduleInstanceCreated =
        await moduleInstanceRepository.createModuleInstance(moduleInstance);

        if (moduleInstanceCreated?.id == null) {
          AppLogger.error(
            '[USECASE] Failed to create ModuleInstance for moduleId=${module.moduleID}',
          );
          continue;
        }

        final moduleInstanceId = moduleInstanceCreated!.id!;
        AppLogger.db(
          '[USECASE] ModuleInstance created: id=$moduleInstanceId '
              '(moduleId=${module.moduleID})',
        );

        final tasks =
        await taskDataSource.getTasksByModuleId(module.moduleID!);

        for (final task in tasks) {
          if (task.taskID == null) continue;

          final taskInstance = TaskInstanceEntity(
            taskId: task.taskID!,
            moduleInstanceId: moduleInstanceId,
            status: TaskStatus.pending,
          );

          final id = await taskInstanceRepository.insert(taskInstance);
          AppLogger.db(
            '[USECASE] TaskInstance created: id=$id '
                '(taskId=${task.taskID}, moduleInstanceId=$moduleInstanceId)',
          );
        }
      }

      createdParticipant =
          participant.copyWith(participantID: participantId);

      AppLogger.info(
        '[USECASE] ✅ Participant + Evaluation hierarchy created '
            '(participantId=$participantId, evaluationId=$evaluationId)',
      );
    });

    return createdParticipant;
  }
}
