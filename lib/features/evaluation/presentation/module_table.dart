import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/constants/enums/progress_status.dart';
import '../../module_instance/domain/module_instance_entity.dart';

class ModuleTable extends StatelessWidget {
  final List<ModuleInstanceEntity> modules;

  const ModuleTable({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
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
              child: Text('Módulo', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Status'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ações'),
            ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [icon, const SizedBox(width: 6), Text(instance.status.description)]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  child: const Text('Iniciar'),
                  onPressed: () {
                    // TODO: implementar lógica de iniciar módulo
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
        return Icon(FluentIcons.check_mark, color: Colors.green);
      case ModuleStatus.inProgress:
        return Icon(FluentIcons.clock, color: Colors.orange);
      case ModuleStatus.pending:
      return const Icon(FluentIcons.circle_ring, color: Colors.grey);
    }
  }
}
