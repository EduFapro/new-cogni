import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_providers.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import '../../../core/constants/enums/progress_status.dart';
import 'task_runner_screen.dart';
import 'countdown_screen.dart';

class ModuleTransitionScreen extends ConsumerWidget {
  final int nextModuleInstanceId;

  const ModuleTransitionScreen({super.key, required this.nextModuleInstanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskRepo = ref.watch(taskInstanceRepositoryProvider);
    final moduleRepo = ref.watch(moduleInstanceRepositoryProvider);

    return FutureBuilder(
      future: Future.wait([
        taskRepo.getByModuleInstance(nextModuleInstanceId),
        moduleRepo.getModuleInstanceById(nextModuleInstanceId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.green, // Visual feedback instantâneo
            child: const Center(child: ProgressRing()),
          );
        }

        final results = snapshot.data as List<dynamic>;
        final instances = results[0] as List<TaskInstanceEntity>;
        final moduleInstance = results[1];
        // Note: moduleInstance might need casting if generic, but dynamic works for simple access.
        // Actually moduleInstance has .module which has title.

        String nextModuleTitle = 'Próximo Módulo';
        if (moduleInstance != null && moduleInstance.module?.title != null) {
          nextModuleTitle = moduleInstance.module!.title;
        }

        if (instances.isEmpty) {
          return Container(
            color: Colors.green,
            child: const Center(
              child: Text(
                'Nenhuma tarefa encontrada para o próximo módulo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        // Ordena por id
        final sorted = [...instances]
          ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

        // Primeira tarefa do próximo módulo
        TaskInstanceEntity? nextTask = sorted.firstWhere(
          (i) => i.status != TaskStatus.completed,
          orElse: () => sorted.first,
        );

        return CountdownScreen(
          targetWidget: TaskRunnerScreen(taskInstanceId: nextTask.id),
          countdownSeconds: 5,
          message: 'Módulo Concluído!\n\nIniciando "$nextModuleTitle" em',
          backgroundColor: Colors.green,
        );
      },
    );
  }
}
