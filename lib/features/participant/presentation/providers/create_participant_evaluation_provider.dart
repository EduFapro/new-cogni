import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/constants/enums/person_enums.dart';
import '../../../../core/database_helper.dart';
import '../../../../core/logger/app_logger.dart';

// Data sources & repositories
import '../../../participant/data/participant_local_datasource.dart';
import '../../../evaluation/data/evaluation_local_datasource.dart';
import '../../../module/data/module_local_datasource.dart';
import '../../../module_instance/data/module_instance_local_datasource.dart';
import '../../../module_instance/data/module_instance_repository_impl.dart';
import '../../../task/data/task_local_datasource.dart';
import '../../../task_instance/data/task_instance_local_datasource.dart';
import '../../../task_instance/data/task_instance_repository_impl.dart';

// Entities & use case
import '../../../participant/domain/participant_entity.dart';
import '../../../evaluation/domain/usecases/create_participant_evaluation_usecase.dart';

/// Riverpod provider for participant + evaluation creation
final createParticipantEvaluationProvider =
AsyncNotifierProvider<CreateParticipantEvaluationNotifier, void>(
  CreateParticipantEvaluationNotifier.new,
);

class CreateParticipantEvaluationNotifier extends AsyncNotifier<void> {
  late final CreateParticipantEvaluationUseCase _useCase;

  @override
  FutureOr<void> build() async {
    final Database db = await DatabaseHelper.instance.database;

    _useCase = CreateParticipantEvaluationUseCase(
      participantDataSource: ParticipantLocalDataSource(),
      evaluationDataSource: EvaluationLocalDataSource(),
      moduleDataSource: ModuleLocalDataSource(),
      moduleInstanceRepository: ModuleInstanceRepositoryImpl(
        localDataSource: ModuleInstanceLocalDataSource(),
      ),
      taskDataSource: TaskLocalDataSource(),
      taskInstanceRepository: TaskInstanceRepositoryImpl(
        localDataSource: TaskInstanceLocalDataSource(),
      ),
      db: db,
    );
  }

  Future<void> createParticipantWithEvaluation({required int evaluatorId}) async {
    AppLogger.info('[PROVIDER] Creating participant with evaluatorId=$evaluatorId');
    state = const AsyncLoading();
    try {
      final participant = ParticipantEntity(
        name: 'Novo',
        surname: 'Participante',
        birthDate: DateTime(1990, 1, 1),
        sex: Sex.male,
        educationLevel: EducationLevel.completeCollege,
      );

      await _useCase.execute(
        participant: participant,
        evaluatorId: evaluatorId,
      );

      AppLogger.info('[PROVIDER] ✅ Participant + Evaluation created successfully');
      state = const AsyncData(null);
    } catch (e, s) {
      AppLogger.error('[PROVIDER] ❌ Failed to create participant', e, s);
      state = AsyncError(e, s);
    }
  }
}
