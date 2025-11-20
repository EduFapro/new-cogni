import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'participant_list_provider.dart';
import 'participant_table.dart';

class ParticipantListScreen extends HookConsumerWidget {
  const ParticipantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantListProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      searchController.addListener(() {
        searchQuery.value = searchController.text.toLowerCase();
      });
      return null;
    }, []);

    return ScaffoldPage(
      header: const PageHeader(title: Text('Meus Pacientes')),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextBox(
              controller: searchController,
              placeholder: 'Buscar por nome ou sobrenome...',
              style: FluentTheme.of(context).typography.body,
            ),
          ),
          Expanded(
            child: participantsAsync.when(
              data: (participants) {
                final filtered = participants
                    .where((p) =>
                    p.fullName.toLowerCase().contains(searchQuery.value))
                    .toList()
                  ..sort((a, b) => a.fullName.compareTo(b.fullName));

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhum paciente encontrado.'));
                }

                return ParticipantTable(participants: filtered);
              },
              loading: () => const Center(child: ProgressRing()),
              error: (error, _) => Center(child: Text('Erro: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
