import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task_instance/domain/task_instance_entity.dart';
import '../../task_instance/domain/task_instance_providers.dart';
import '../../../core/constants/enums/progress_status.dart';
import 'task_runner_screen.dart';
import 'countdown_screen.dart';

class ModuleTaskEntryScreen extends ConsumerWidget {
  final int moduleInstanceId;
  final Color? backgroundColor;
  final String? customMessage;

  const ModuleTaskEntryScreen({
    super.key,
    required this.moduleInstanceId,
    this.backgroundColor,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskInstanceRepositoryProvider);

    return FutureBuilder<List<TaskInstanceEntity>>(
      future: repo.getByModuleInstance(moduleInstanceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: ProgressRing());
        }

        final instances = snapshot.data!;
        if (instances.isEmpty) {
          return const Center(
            child: Text('Nenhuma tarefa encontrada para este módulo'),
          );
        }

        // Ordena por id (outra opção seria por posição da Task, mas aqui só temos o instance)
        final sorted = [...instances]
          ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

        // Próxima pendente
        TaskInstanceEntity next = sorted.firstWhere(
          (i) => i.status != TaskStatus.completed,
          orElse: () => sorted.first,
        );

        final isResuming = sorted.any((t) => t.status == TaskStatus.completed);
        final defaultMessage = isResuming
            ? 'Retomando avaliação em'
            : 'Iniciando avaliação em';

        return CountdownScreen(
          targetWidget: TaskRunnerScreen(taskInstanceId: next.id),
          countdownSeconds: 5,
          message: customMessage ?? defaultMessage,
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}
