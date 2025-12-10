import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/enums/progress_status.dart';
import '../../../../core/constants/enums/task_mode.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../shared/encryption/file_encryption_helper.dart';
import '../../../shared/utils/recording_file_path_helper.dart';
import '../../evaluation/presentation/evaluation_provider.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import '../../participant/presentation/participant_list_provider.dart';
import '../../participant/presentation/participant_provider.dart';
import '../../../providers/evaluator_providers.dart';
import '../../recording_file/data/recording_file_providers.dart';
import '../../recording_file/domain/recording_file_entity.dart';
import '../../task/domain/task_entity.dart';
import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_providers.dart';
import 'image_record_task_screen.dart';

import 'media_record_task_screen.dart';

import '../../../../core/utils/video_path_service.dart';
import '../../evaluation/domain/evaluation_entity.dart';

final evaluationByTaskInstanceIdProvider =
    FutureProvider.family<EvaluationEntity?, int>((ref, taskInstanceId) async {
      final taskInstance = await ref.watch(
        taskInstanceByIdProvider(taskInstanceId).future,
      );
      if (taskInstance == null) return null;

      final moduleInstanceRepo = ref.watch(moduleInstanceRepositoryProvider);
      final moduleInstance = await moduleInstanceRepo.getModuleInstanceById(
        taskInstance.moduleInstanceId,
      );
      if (moduleInstance == null) return null;

      final evaluationRepo = ref.watch(evaluationRepositoryProvider);
      return evaluationRepo.getById(moduleInstance.evaluationId);
    });

class TaskRunnerScreen extends ConsumerWidget {
  final TaskEntity? task;
  final int? taskInstanceId;

  const TaskRunnerScreen({super.key, this.task, this.taskInstanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task != null) {
      // Preview mode: no evaluation context, default to Joana or null
      return buildForTask(context, task!, ref, null);
    }

    if (taskInstanceId != null) {
      final asyncInstance = ref.watch(
        taskInstanceByIdProvider(taskInstanceId!),
      );
      final asyncEvaluation = ref.watch(
        evaluationByTaskInstanceIdProvider(taskInstanceId!),
      );

      return asyncInstance.when(
        data: (instance) {
          if (instance == null || instance.task == null) {
            return const Center(child: Text('Task instance not found'));
          }

          return asyncEvaluation.when(
            data: (evaluation) {
              return buildForTask(context, instance.task!, ref, evaluation);
            },
            loading: () => const Center(child: ProgressRing()),
            error: (err, stack) =>
                Center(child: Text('Error loading evaluation: $err')),
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      );
    }

    return const Center(child: Text('No task or instance ID provided'));
  }

  Widget buildForTask(
    BuildContext context,
    TaskEntity task,
    WidgetRef ref,
    EvaluationEntity? evaluation,
  ) {
    // Use FutureBuilder to load assets if needed, or better: use a provider.
    // Since we are inside a build method, we should avoid async work directly.
    // However, AssetManifest loading is async.
    // We can use a FutureBuilder here.

    return FutureBuilder<List<String>>(
      future: _loadAssetKeys(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ProgressRing());
        }

        final allAssets = snapshot.data ?? [];

        // Resolve video path dynamically
        String? resolvedVideoPath;
        if (evaluation != null) {
          resolvedVideoPath = VideoPathService.resolveVideoPath(
            task: task,
            evaluation: evaluation,
            allAssets: allAssets,
          );
        }

        // Fallback to seed path if dynamic resolution failed (and if it's not null)
        if (resolvedVideoPath == null && task.videoAssetPath != null) {
          // But seed path is likely wrong (old structure).
          // We might want to try to adapt it or just leave it null.
          // For now, let's NOT fallback to the old path if we expect new structure.
          // Or maybe we can try to find it in the new structure using the old filename?
          // Let's stick to the dynamic resolution which is robust.
        }

        // Para TaskMode.play com vídeo
        if (task.taskMode == TaskMode.play &&
            resolvedVideoPath != null &&
            resolvedVideoPath.isNotEmpty) {
          return MediaRecordTaskScreen(
            videoAssetPath: resolvedVideoPath,
            requiresRecording: false,
            onRecordingFinished: (filePath, duration) => _onTaskFinished(
              context,
              ref,
              recordingPath: filePath, // Will be empty
              recordingDuration: duration, // Will be zero
            ),
          );
        }

        // Calculate max duration
        final maxDuration = task.maxDuration > 0
            ? Duration(seconds: task.maxDuration)
            : null;

        // Para TaskMode.record com vídeo
        if (task.taskMode == TaskMode.record &&
            resolvedVideoPath != null &&
            resolvedVideoPath.isNotEmpty) {
          return MediaRecordTaskScreen(
            videoAssetPath: resolvedVideoPath,
            maxDuration: maxDuration,
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
            maxDuration: maxDuration,
            onRecordingFinished: (filePath, duration) => _onTaskFinished(
              context,
              ref,
              recordingPath: filePath,
              recordingDuration: duration,
            ),
          );
        }

        // Error screen...
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
                    'Vídeo não encontrado para Avatar: ${evaluation?.avatar ?? "N/A"}\n'
                    'Módulo: ${task.moduleID}, Tarefa: ${task.position}',
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
      },
    );
  }

  Future<List<String>> _loadAssetKeys(BuildContext context) async {
    try {
      final manifestJson = await DefaultAssetBundle.of(
        context,
      ).loadString('AssetManifest.json');
      // Simple parsing to extract keys.
      // The manifest is a JSON map where keys are asset paths.
      // We can use a regex or simple string manipulation if we want to avoid dart:convert import,
      // but importing dart:convert is better.
      // Since I can't easily add imports here without messing up the file,
      // I will assume dart:convert is available or use a regex.
      // Actually, TaskRunnerScreen imports dart:io, but not dart:convert.
      // I should add dart:convert import in a separate step or use a regex.

      // Regex approach to avoid import issues in this step:
      final keys = <String>[];
      final regExp = RegExp(r'"(assets/[^"]+)"');
      final matches = regExp.allMatches(manifestJson);
      for (final match in matches) {
        if (match.groupCount >= 1) {
          keys.add(match.group(1)!);
        }
      }
      return keys;
    } catch (e) {
      AppLogger.error('Failed to load AssetManifest', e);
      return [];
    }
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

    // 2) Se tiver gravação, processa o arquivo
    if (recordingPath != null && recordingPath.isNotEmpty) {
      AppLogger.info('💾 Processing recording: $recordingPath');

      try {
        // Get evaluator and participant info for proper file naming
        final moduleInstance = await moduleInstanceRepo.getModuleInstanceById(
          currentInstance.moduleInstanceId,
        );

        if (moduleInstance == null) {
          AppLogger.error('❌ Module instance not found');
          throw Exception('Module instance not found');
        }

        final evaluationRepo = ref.read(evaluationRepositoryProvider);
        final evaluation = await evaluationRepo.getById(
          moduleInstance.evaluationId,
        );

        if (evaluation == null) {
          AppLogger.error('❌ Evaluation not found');
          throw Exception('Evaluation not found');
        }

        final participantRepo = ref.read(participantRepositoryProvider);
        final participant = await participantRepo.getById(
          evaluation.participantID,
        );

        if (participant == null) {
          AppLogger.error('❌ Participant not found');
          throw Exception('Participant not found');
        }

        // Get evaluator info from current user
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null || currentUser.evaluatorId == null) {
          AppLogger.error('❌ No current user or evaluator ID');
          throw Exception('No current user');
        }

        final evaluatorId = currentUser.evaluatorId!;
        // Evaluator names are now stored as plain text
        final evaluatorName = '${currentUser.name} ${currentUser.surname}';

        // Get task entity ID
        final taskEntityId =
            currentInstance.task?.taskID ?? currentInstance.taskId;

        // Participant names are now stored as plain text
        final participantName = '${participant.name} ${participant.surname}';

        // Generate proper file path
        final properPath = await RecordingFilePathHelper.generateRecordingPath(
          evaluatorId: evaluatorId,
          evaluatorName: evaluatorName,
          participantId: participant.participantID!,
          participantName: participantName,
          taskEntityId: taskEntityId!,
        );

        // Move the temporary recording to the proper location
        final tempFile = File(recordingPath);

        if (await tempFile.exists()) {
          await tempFile.copy(properPath);
          await tempFile.delete();
          AppLogger.info('✅ Moved file from $recordingPath to $properPath');
        } else {
          AppLogger.error('❌ Temporary file not found: $recordingPath');
          throw Exception('Temporary file not found');
        }

        // Encrypt the file
        final encryptedPath = await FileEncryptionHelper.encryptFile(
          properPath,
        );
        AppLogger.info('🔐 Encrypted file: $encryptedPath');

        // Delete the original unencrypted file
        await FileEncryptionHelper.deleteOriginalFile(properPath);

        // Save encrypted path to database
        final entity = RecordingFileEntity(
          taskInstanceId: currentInstance.id!,
          filePath: encryptedPath, // Save the .enc path
        );
        await recordingRepo.insert(entity);
        AppLogger.info('✅ Saved encrypted recording path to database');
      } catch (e, s) {
        AppLogger.error('❌ Failed to process recording file', e, s);
        // Even if file processing fails, continue with task completion
        // The recording still happened, just the file organization failed
      }
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
