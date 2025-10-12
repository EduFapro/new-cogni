import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/database_helper.dart';
import '../../../../core/logger/app_logger.dart';
import '../evaluation/data/evaluation_local_datasource.dart';
import '../evaluation/domain/usecases/create_participant_evaluation_usecase.dart';
import '../module/data/module_local_datasource.dart';
import '../module_instance/data/module_instance_local_datasource.dart';
import '../module_instance/data/module_instance_repository_impl.dart';
import '../module_instance/domain/module_instance_repository.dart';
import '../task/data/task_local_datasource.dart';
import '../task_instance/data/task_instance_local_datasource.dart';
import '../task_instance/data/task_instance_repository_impl.dart';
import '../task_instance/domain/task_instance_repository.dart';
import 'data/participant_local_datasource.dart';


final participantLocalDataSourceProvider =
Provider<ParticipantLocalDataSource>((ref) => ParticipantLocalDataSource());

final evaluationLocalDataSourceProvider =
Provider<EvaluationLocalDataSource>((ref) => EvaluationLocalDataSource());

final moduleLocalDataSourceProvider =
Provider<ModuleLocalDataSource>((ref) => ModuleLocalDataSource());

final moduleInstanceLocalDataSourceProvider =
Provider<ModuleInstanceLocalDataSource>((ref) => ModuleInstanceLocalDataSource());

final moduleInstanceRepositoryProvider = Provider<ModuleInstanceRepository>((ref) {
  final ds = ref.watch(moduleInstanceLocalDataSourceProvider);
  return ModuleInstanceRepositoryImpl(localDataSource: ds);
});

final taskLocalDataSourceProvider =
Provider<TaskLocalDataSource>((ref) => TaskLocalDataSource());

final taskInstanceLocalDataSourceProvider =
Provider<TaskInstanceLocalDataSource>((ref) => TaskInstanceLocalDataSource());

final taskInstanceRepositoryProvider = Provider<TaskInstanceRepository>((ref) {
  final ds = ref.watch(taskInstanceLocalDataSourceProvider);
  return TaskInstanceRepositoryImpl(localDataSource: ds);
});

// --- Use Case Provider ---
final createParticipantEvaluationUseCaseProvider =
Provider<CreateParticipantEvaluationUseCase>((ref) {
  final participantDS = ref.watch(participantLocalDataSourceProvider);
  final evaluationDS = ref.watch(evaluationLocalDataSourceProvider);
  final moduleDS = ref.watch(moduleLocalDataSourceProvider);
  final moduleInstanceRepo = ref.watch(moduleInstanceRepositoryProvider);
  final taskDS = ref.watch(taskLocalDataSourceProvider);
  final taskInstanceRepo = ref.watch(taskInstanceRepositoryProvider);

  final dbFuture = DatabaseHelper.instance.database;

  AppLogger.debug('[PROVIDER] createParticipantEvaluationUseCase initialized');

  return CreateParticipantEvaluationUseCase(
    participantDataSource: participantDS,
    evaluationDataSource: evaluationDS,
    moduleDataSource: moduleDS,
    moduleInstanceRepository: moduleInstanceRepo,
    taskDataSource: taskDS,
    taskInstanceRepository: taskInstanceRepo,
    db: dbFuture as Database,
  );
});
