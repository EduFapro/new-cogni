import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/enums/progress_status.dart';
import '../../../../core/constants/enums/task_mode.dart';
import '../../../../core/logger/app_logger.dart';
import '../../evaluation/presentation/evaluation_provider.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import '../../participant/presentation/participant_list_provider.dart';
import '../../recording_file/data/recording_file_providers.dart';
import '../../recording_file/domain/recording_file_entity.dart';
import '../../task/domain/task_entity.dart';
import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_providers.dart';
import 'image_record_task_screen.dart';
import 'media_prompt_task_screen.dart';
import 'media_record_task_screen.dart';

class TaskRunnerScreen extends ConsumerWidget {
  final TaskEntity? task;
  final int? taskInstanceId;

  const TaskRunnerScreen({super.key, this.task, this.taskInstanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task != null) {
      return buildForTask(context, task!, ref);
    }

    if (taskInstanceId != null) {
      final asyncInstance = ref.watch(
        taskInstanceByIdProvider(taskInstanceId!),
      );

      return asyncInstance.when(
        data: (instance) {
          if (instance == null || instance.task == null) {
            return const Center(child: Text('Task instance not found'));
          }
          return buildForTask(context, instance.task!, ref);
        },
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
    }

    return const Center(child: Text('No task or instance ID provided'));
  }

  Widget buildForTask(BuildContext context, TaskEntity task, WidgetRef ref) {
    // Para TaskMode.play com vídeo
    if (task.taskMode == TaskMode.play &&
        task.videoAssetPath != null &&
        task.videoAssetPath!.isNotEmpty) {
      return MediaPromptTaskScreen(
        videoAssetPath: task.videoAssetPath!,
        onCompleted: () => _onTaskFinished(context, ref),
      );
    }

    // Para TaskMode.record com vídeo
    if (task.taskMode == TaskMode.record &&
        task.videoAssetPath != null &&
        task.videoAssetPath!.isNotEmpty) {
      return MediaRecordTaskScreen(
        videoAssetPath: task.videoAssetPath!,
        onRecordingFinished: (filePath, duration) => _onTaskFinished(
          context,
          ref,
          recordingPath: filePath,
          recordingDuration: duration,
        ),
      );
    }

    // Para TaskMode.record com imagem
    if (task.taskMode == TaskMode.record &&
        task.imageAssetPath.isNotEmpty &&
        task.imageAssetPath != 'no_image') {
      return ImageRecordTaskScreen(
        imageAssetPath: task.imageAssetPath,
        onRecordingFinished: (filePath, duration) => _onTaskFinished(
          context,
          ref,
          recordingPath: filePath,
          recordingDuration: duration,
        ),
      );
    }

    // Erro: configuração inválida - missing video/image
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FluentIcons.error_badge,
                size: 80,
                color: Color(0xFFE81123),
              ),
              const SizedBox(height: 24),
              const Text(
                'Erro de Configuração',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Esta tarefa está configurada incorretamente.\n'
                'Entre em contato com o suporte técnico.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTaskFinished(
    BuildContext context,
    WidgetRef ref, {
    String? recordingPath,
    Duration? recordingDuration,
  }) async {
    if (taskInstanceId == null) return;

    AppLogger.info(
      '🎯 _onTaskFinished called for taskInstanceId=$taskInstanceId',
    );

    final taskInstanceRepo = ref.read(taskInstanceRepositoryProvider);
    final recordingRepo = ref.read(recordingFileRepositoryProvider);
    final moduleInstanceRepo = ref.read(moduleInstanceRepositoryProvider);

    // 1) Carrega a instância atual pra pegar o moduleInstanceId
    final currentInstance = await taskInstanceRepo.getById(taskInstanceId!);
    if (currentInstance == null) {
      AppLogger.error('❌ Current task instance not found: $taskInstanceId');
      return;
    }

    AppLogger.info(
      '✅ Current instance: ID=${currentInstance.id}, moduleInstanceId=${currentInstance.moduleInstanceId}',
    );

    // 2) Se tiver gravação, salva em recording_files
    if (recordingPath != null && recordingPath.isNotEmpty) {
      AppLogger.info('💾 Saving recording: $recordingPath');
      final entity = RecordingFileEntity(
        taskInstanceId: currentInstance.id!,
        filePath: recordingPath,
      );
      await recordingRepo.insert(entity);
    }

    // 3) Marca a task como concluída
    final durationStr = recordingDuration?.inSeconds.toString();
    AppLogger.info(
      '✓ Marking task $taskInstanceId as completed (duration: $durationStr seconds)',
    );
    await taskInstanceRepo.markAsCompleted(
      taskInstanceId!,
      duration: durationStr,
    );

    // 4) Busca todas as tasks do módulo pra descobrir a próxima
    final instances = await taskInstanceRepo.getByModuleInstance(
      currentInstance.moduleInstanceId,
    );

    if (instances.isEmpty) {
      AppLogger.error(
        '❌ No task instances found for moduleInstanceId=${currentInstance.moduleInstanceId}',
      );
      if (context.mounted) Navigator.pop(context);
      return;
    }

    AppLogger.info('📋 Found ${instances.length} task instances in module');

    // Ordena por id (aproximação da ordem)
    final sorted = [...instances]
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    final currentIndex = sorted.indexWhere((i) => i.id == currentInstance.id);
    AppLogger.info(
      '📍 Current task is at index $currentIndex (ID=${currentInstance.id})',
    );

    TaskInstanceEntity? nextInstance;

    // Procura a próxima não-concluída depois da atual
    for (var i = currentIndex + 1; i < sorted.length; i++) {
      AppLogger.info(
        '🔍 Checking task at index $i: ID=${sorted[i].id}, status=${sorted[i].status}',
      );
      if (sorted[i].status != TaskStatus.completed) {
        nextInstance = sorted[i];
        AppLogger.info('✨ Found next pending task: ID=${nextInstance.id}');
        break;
      }
    }

    if (nextInstance == null) {
      AppLogger.info('🏁 No more pending tasks found');

      // Se não tem próxima, verifica se todas estão concluídas para marcar o módulo
      final allCompleted = sorted.every(
        (i) => i.status == TaskStatus.completed,
      );

      AppLogger.info('📊 All tasks completed: $allCompleted');

      // Get the module instance to retrieve the evaluationId (needed for provider invalidation later)
      final moduleInstance = await moduleInstanceRepo.getModuleInstanceById(
        currentInstance.moduleInstanceId,
      );
      final evaluationId = moduleInstance?.evaluationId;

      if (allCompleted) {
        AppLogger.info(
          '🎉 Marking module ${currentInstance.moduleInstanceId} as completed',
        );
        await moduleInstanceRepo.setModuleInstanceStatus(
          currentInstance.moduleInstanceId,
          ModuleStatus.completed,
        );

        // Check if all modules in the evaluation are completed
        if (evaluationId != null) {
          AppLogger.info(
            '📊 Checking if all modules in evaluation $evaluationId are completed',
          );

          final evaluationRepo = ref.read(evaluationRepositoryProvider);
          final allModulesInEvaluation = await moduleInstanceRepo
              .getModuleInstancesByEvaluationId(evaluationId);

          final allModulesCompleted = allModulesInEvaluation.every(
            (m) => m.status == ModuleStatus.completed,
          );

          if (allModulesCompleted) {
            AppLogger.info(
              '🎊 All modules completed! Marking evaluation $evaluationId as completed',
            );
            await evaluationRepo.setEvaluationStatus(
              evaluationId,
              EvaluationStatus.completed,
            );
          } else {
            AppLogger.info(
              '⏳ Some modules still pending in evaluation $evaluationId',
            );
          }
        }
      }

      // Não tem próxima → volta pra tela anterior (lista de módulos)
      if (context.mounted) {
        AppLogger.info('⬅️ Navigating back to module list');

        // Invalidate the provider to refresh the module list with updated status
        if (evaluationId != null) {
          ref.invalidate(moduleInstancesByEvaluationProvider(evaluationId));
          // Also invalidate participant list to show updated evaluation status
          ref.invalidate(participantListProvider);
        }

        Navigator.pop(context);
      }
    } else {
      // Navigate directly to next task
      // The transition countdown is shown within MediaRecordTaskScreen
      if (context.mounted) {
        AppLogger.info('➡️ Navigating to next task: ID=${nextInstance.id}');
        Navigator.pushReplacement(
          context,
          FluentPageRoute(
            builder: (_) => TaskRunnerScreen(taskInstanceId: nextInstance!.id),
          ),
        );
      }
    }
  }
}
