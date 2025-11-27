import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/enums/progress_status.dart';
import '../../module_instance/domain/module_instance_entity.dart';
import '../../task_runner/presentation/module_task_entry_screen.dart';

class ModuleTable extends ConsumerWidget {
  final List<ModuleInstanceEntity> modules;

  const ModuleTable({super.key, required this.modules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(4),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE4ECF7)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Módulo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(padding: EdgeInsets.all(8.0), child: Text('Status')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('Ações')),
          ],
        ),
        ...modules.map((instance) {
          final title = instance.module?.title ?? 'Sem título';
          final icon = _statusIcon(instance.status);

          return TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFD0D0D0))),
            ),
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    icon,
                    const SizedBox(width: 6),
                    Text(instance.status.description),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text('Iniciar'),
                  onPressed: () {
                    final moduleInstId = instance.id;
                    if (moduleInstId == null) return;

                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (_) => ModuleTaskEntryScreen(
                          moduleInstanceId: moduleInstId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _statusIcon(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return const Icon(FluentIcons.check_mark, color: Color(0xFF107C10));
      case ModuleStatus.inProgress:
        return const Icon(FluentIcons.play, color: Color(0xFF0078D4));
      case ModuleStatus.pending:
      default:
        return const Icon(FluentIcons.circle_stop, color: Color(0xFF605E5C));
    }
  }
}
