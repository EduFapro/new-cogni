import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'participant_list_provider.dart';

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
                p.name.toLowerCase().contains(searchQuery.value) ||
                    p.surname.toLowerCase().contains(searchQuery.value))
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhum paciente encontrado.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final participant = filtered[index];
                    return ListTile(
                      title: Text('${participant.name} ${participant.surname}'),
                      subtitle: Text('ID: ${participant.participantID}'),
                      leading: const Icon(FluentIcons.contact),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ContentDialog(
                            title: const Text('Detalhes do Paciente'),
                            content: Text(
                              'Nome: ${participant.name}\n'
                                  'Sobrenome: ${participant.surname}\n'
                                  'ID: ${participant.participantID}',
                            ),
                            actions: [
                              Button(
                                child: const Text('Fechar'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: ProgressRing()),
              error: (error, stack) =>
                  Center(child: Text('Erro ao carregar pacientes: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
