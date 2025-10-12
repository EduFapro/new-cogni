import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../participant/domain/participant_entity.dart';
import '../../../participant/data/participant_local_datasource.dart';
import '../../../evaluation/domain/evaluation_entity.dart';
import '../../../evaluation/data/evaluation_local_datasource.dart';
import '../../../module/data/module_local_datasource.dart';
import '../../../module_instance/domain/module_instance_entity.dart';
import '../../../module_instance/domain/module_instance_repository.dart';
import '../../../task/data/task_local_datasource.dart';
import '../../../task_instance/domain/task_instance_entity.dart';
import '../../../task_instance/domain/task_instance_repository.dart';
import '../../../../core/constants/enums/progress_status.dart';
import '../../../../core/logger/app_logger.dart';

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

  Future<void> execute({
    required ParticipantEntity participant,
    required int evaluatorId,
    int language = 1,
  }) async {
    AppLogger.info('[USECASE] Starting participant creation → ${participant.fullName}');

    await db.transaction((txn) async {
      final participantId = await participantDataSource.insertParticipant(txn, participant.toMap());
      AppLogger.db('Inserted participant ID=$participantId');

      final evaluation = EvaluationEntity(
        evaluatorID: evaluatorId,
        participantID: participantId!,
        status: EvaluationStatus.pending,
        language: language,
      );
      final evaluationId = await evaluationDataSource.insertEvaluation(txn, evaluation.toMap());
      AppLogger.db('Created evaluation ID=$evaluationId');

      final modules = await moduleDataSource.getAllModules();
      for (final module in modules) {
        final moduleInstance = ModuleInstanceEntity(
          moduleId: module.moduleID!,
          evaluationId: evaluationId!,
          status: ModuleStatus.pending,
        );
        final moduleInstanceId = await moduleInstanceRepository
            .createModuleInstance(moduleInstance)
            .then((mi) => mi?.id);

        final tasks = await taskDataSource.getTasksByModuleId(module.moduleID!);
        for (final task in tasks) {
          final taskInstance = TaskInstanceEntity(
            taskId: task.taskID!,
            moduleInstanceId: moduleInstanceId!,
            status: TaskStatus.pending,
          );
          await taskInstanceRepository.insert(taskInstance);
        }
      }

      AppLogger.info('[USECASE] ✅ Participant + Evaluation hierarchy created successfully');
    });
  }
}
