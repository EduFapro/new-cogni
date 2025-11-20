import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import 'module_table.dart';

class ModuleEvaluationScreen extends HookConsumerWidget {
  final int evaluationId;

  const ModuleEvaluationScreen({super.key, required this.evaluationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(moduleInstanceRepositoryProvider);

    final future = useMemoized(
          () => repo.getModuleInstancesByEvaluationId(evaluationId),
      [evaluationId],
    );
    final snapshot = useFuture(future);

    if (!snapshot.hasData) {
      return const Center(child: ProgressRing());
    }

    final modules = snapshot.data!;

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Avaliação por Módulo'),
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      content: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(child: ModuleTable(modules: modules)),
        ],
      ),
    );

  }
}
