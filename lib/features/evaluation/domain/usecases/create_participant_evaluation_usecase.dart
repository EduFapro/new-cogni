import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/constants/enums/progress_status.dart';

import '../../../participant/data/participant_security_helper.dart';
import '../../../participant/domain/participant_entity.dart';
import '../../../participant/data/participant_local_datasource.dart';

import '../../../evaluation/data/evaluation_local_datasource.dart';
import '../../../evaluation/domain/evaluation_entity.dart';

import '../../../module/data/module_local_datasource.dart';
import '../../../module/domain/module_repository.dart'; // ✅ Required

import '../../../module_instance/domain/module_instance_entity.dart';
import '../../../module_instance/domain/module_instance_repository.dart';

import '../../../task/data/task_local_datasource.dart';

import '../../../task_instance/domain/task_instance_entity.dart';
import '../../../task_instance/domain/task_instance_repository.dart';

class CreateParticipantEvaluationUseCase {
  final ParticipantLocalDataSource participantDataSource;
  final EvaluationLocalDataSource evaluationDataSource;
  final ModuleLocalDataSource moduleDataSource;
  final ModuleRepository moduleRepository; // ✅ Added
  final ModuleInstanceRepository moduleInstanceRepository;
  final TaskLocalDataSource taskDataSource;
  final TaskInstanceRepository taskInstanceRepository;
  final Database db;

  CreateParticipantEvaluationUseCase({
    required this.participantDataSource,
    required this.evaluationDataSource,
    required this.moduleDataSource,
    required this.moduleRepository, // ✅ Added
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
    AppLogger.info('[USECASE] Starting participant creation: ${participant.name} '
        '(selectedModules=$selectedModuleIds)');

    late final ParticipantEntity createdParticipant;

    try {
      await db.transaction((txn) async {
        // 1) Insert participant
        final hashedParticipant = participant.copyWith(
          name: ParticipantSecurityHelper.hashSha256(participant.name),
          surname: ParticipantSecurityHelper.hashSha256(participant.surname),
        );

        final participantId = await participantDataSource.insertParticipant(txn, hashedParticipant.toMap());
        AppLogger.db('[USECASE] Participant inserted: id=$participantId');

        // 2) Insert evaluation
        final evaluation = EvaluationEntity(
          evaluatorID: evaluatorId,
          participantID: participantId!,
          status: EvaluationStatus.pending,
          language: language,
        );

        final evaluationId = await evaluationDataSource.insertEvaluation(txn, evaluation.toMap());
        AppLogger.db('[USECASE] Evaluation created: id=$evaluationId');

        // 3) Fetch and filter modules
        AppLogger.info('[USECASE] Fetching all modules...');
        final allModules = await moduleRepository
            .getAllModules()
            .timeout(const Duration(seconds: 5), onTimeout: () {
          AppLogger.error('[USECASE] ❌ Timeout while fetching modules');
          throw Exception('Timeout fetching modules');
        });

        AppLogger.info('[USECASE] Retrieved ${allModules.length} modules');

        final modulesToUse = selectedModuleIds.isEmpty
            ? allModules
            : allModules
            .where((m) => m.moduleID != null && selectedModuleIds.contains(m.moduleID))
            .toList();

        AppLogger.info('[USECASE] Using ${modulesToUse.length} module(s) for evaluation');

        // 4) Create module instances and task instances
        for (final module in modulesToUse) {
          if (module.moduleID == null) continue;

          final moduleInstance = ModuleInstanceEntity(
            moduleId: module.moduleID!,
            status: ModuleStatus.pending,
          );

          final moduleInstanceCreated = await moduleInstanceRepository.createModuleInstance(moduleInstance);

          final moduleInstanceId = moduleInstanceCreated?.id;
          if (moduleInstanceId == null) {
            AppLogger.error('[USECASE] Failed to create ModuleInstance for moduleId=${module.moduleID}');
            continue;
          }

          AppLogger.db('[USECASE] ModuleInstance created: id=$moduleInstanceId');


          final tasks = await taskDataSource.getTasksByModuleId(module.moduleID!);
          for (final task in tasks) {
            if (task.taskID == null) continue;

            final taskInstance = TaskInstanceEntity(
              taskId: task.taskID!,
              moduleInstanceId: moduleInstanceId,
              status: TaskStatus.pending,
            );

            final taskInstanceId = await taskInstanceRepository.insert(taskInstance);
            AppLogger.db('[USECASE] TaskInstance created: id=$taskInstanceId (taskId=${task.taskID})');
          }
        }

        createdParticipant = participant.copyWith(participantID: participantId);
        AppLogger.info('[USECASE] ✅ Participant + Evaluation hierarchy created');
      });

      return createdParticipant;
    } catch (e, s) {
      AppLogger.error('[USECASE] ❌ Transaction failed during participant evaluation creation', e, s);
      rethrow;
    }
  }
}
