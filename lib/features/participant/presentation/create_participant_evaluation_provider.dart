import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/constants/enums/person_enums.dart';
import '../../../core/database_helper.dart';
import '../../../core/logger/app_logger.dart';
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

final createParticipantEvaluationProvider =
AsyncNotifierProvider<CreateParticipantEvaluationNotifier, ParticipantEntity?>(
  CreateParticipantEvaluationNotifier.new,
);

class CreateParticipantEvaluationNotifier extends AsyncNotifier<ParticipantEntity?> {
  late final CreateParticipantEvaluationUseCase _useCase;

  @override
  FutureOr<ParticipantEntity?> build() async {
    final Database db = await DatabaseHelper.instance.database;

    _useCase = CreateParticipantEvaluationUseCase(
      participantDataSource: ParticipantLocalDataSource(),
      evaluationDataSource: EvaluationLocalDataSource(),
      moduleDataSource: ModuleLocalDataSource(),
      moduleInstanceRepository:
      ModuleInstanceRepositoryImpl(localDataSource: ModuleInstanceLocalDataSource()),
      taskDataSource: TaskLocalDataSource(),
      taskInstanceRepository:
      TaskInstanceRepositoryImpl(localDataSource: TaskInstanceLocalDataSource()),
      db: db,
    );

    return null;
  }

  Future<void> createParticipantWithEvaluation({required int evaluatorId}) async {
    state = const AsyncLoading();
    AppLogger.info('[PROVIDER] Creating participant for evaluator=$evaluatorId');
    try {
      final participant = ParticipantEntity(
        name: 'Novo',
        surname: 'Participante',
        birthDate: DateTime(1990, 1, 1),
        sex: Sex.male,
        educationLevel: EducationLevel.completeCollege,
      );

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
