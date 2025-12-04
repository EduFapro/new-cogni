import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:segundo_cogni/features/participant/presentation/participant_status_filter_enum.dart';

import '../../../core/utils/file_helper.dart';
import 'participant_list_provider.dart';
import 'participant_table.dart';

class ParticipantListScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final statusFilter = useState(ParticipantStatusFilter.all);

    final participantsAsync = ref.watch(participantListProvider);

    return participantsAsync.when(
      data: (participants) {
        final filtered = participants.where((p) {
          final query = searchQuery.value.toLowerCase();
          final name = p.fullName.toLowerCase();
          final status = p.statusLabel.toLowerCase();
          final evalDate = p.evaluationDateFormatted.toLowerCase();

          final matchesText =
              name.contains(query) ||
              status.contains(query) ||
              evalDate.contains(query);
          final matchesFilter = switch (statusFilter.value) {
            ParticipantStatusFilter.all => true,
            ParticipantStatusFilter.completed => p.isCompleted,
            ParticipantStatusFilter.pending => p.isPending,
            ParticipantStatusFilter.inProgress => p.isInProgress,
            ParticipantStatusFilter.notStarted => p.evaluation == null,
          };

          return matchesText && matchesFilter;
        }).toList()..sort((a, b) => a.fullName.compareTo(b.fullName));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: 'Buscar por nome, status ou data...',
                      onChanged: (text) => searchQuery.value = text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ComboBox<ParticipantStatusFilter>(
                    value: statusFilter.value,
                    items: ParticipantStatusFilter.values
                        .map(
                          (f) => ComboBoxItem(value: f, child: Text(f.label)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) statusFilter.value = val;
                    },
                    placeholder: const Text('Filtrar status'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    child: const Text('Exportar Excel'),
                    onPressed: () async {
                      await exportParticipantsToExcel(filtered);
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => ContentDialog(
                            title: const Text('Exportado!'),
                            content: const Text(
                              'Arquivo salvo em documentos do app.',
                            ),
                            actions: [
                              Button(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: ParticipantTable(participants: filtered)),
          ],
        );
      },
      loading: () => const Center(child: ProgressRing()),
      error: (err, st) =>
          Center(child: Text('Erro ao carregar participantes: $err')),
    );
  }
}
