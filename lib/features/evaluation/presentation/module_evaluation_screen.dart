import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../module_instance/presentation/module_instance_provider.dart';
import '../../participant/presentation/participant_list_provider.dart';
import 'module_table.dart';

class ModuleEvaluationScreen extends ConsumerWidget {
  final int evaluationId;

  const ModuleEvaluationScreen({super.key, required this.evaluationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the provider which will automatically refresh when invalidated
    final modulesAsync = ref.watch(
      moduleInstancesByEvaluationProvider(evaluationId),
    );

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Avaliação por Módulo'),
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () {
            // Invalidate the provider when navigating back to force a refresh
            ref.invalidate(moduleInstancesByEvaluationProvider(evaluationId));
            // Also invalidate participant list to show updated evaluation status
            ref.invalidate(participantListProvider);
            Navigator.pop(context);
          },
        ),
      ),
      content: modulesAsync.when(
        data: (modules) => Column(
          children: [
            const SizedBox(height: 12),
            Expanded(child: ModuleTable(modules: modules)),
          ],
        ),
        loading: () => const Center(child: ProgressRing()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar módulos: $error')),
      ),
    );
  }
}
