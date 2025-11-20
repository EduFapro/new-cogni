import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'participant_list_provider.dart';

class ParticipantListScreen extends ConsumerWidget {
  const ParticipantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantListProvider);

    return ScaffoldPage(
      header: const PageHeader(title: Text('Meus Pacientes')),
      content: participantsAsync.when(
        data: (participants) {
          if (participants.isEmpty) {
            return const Center(child: Text('Nenhum paciente encontrado.'));
          }
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return ListTile(
                title: Text('${participant.name} ${participant.surname}'),
                subtitle: Text('ID: ${participant.participantID}'),
                leading: const Icon(FluentIcons.contact),
                onPressed: () {
                  // TODO: Navigate to participant details or evaluation
                },
              );
            },
          );
        },
        loading: () => const Center(child: ProgressRing()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar pacientes: $error')),
      ),
    );
  }
}
