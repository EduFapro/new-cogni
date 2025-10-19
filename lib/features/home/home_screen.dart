import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../evaluator/data/evaluator_model.dart';
import '../../providers/providers.dart';
import '../participant/domain/participant_entity.dart';
import '../participant/presentation/create_participant_evaluation_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EvaluatorModel? user = ref.watch(currentUserProvider);

    // Listen for creation state changes
    ref.listen(createParticipantEvaluationProvider, (_, next) {
      next.whenOrNull(
        data: (participant) => _showSuccessInfoBar(context, ref, participant),
        error: (e, _) => _showErrorInfoBar(context, e.toString()),
      );
    });

    return NavigationView(
      content: ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            "Bem-vindo, ${user?.name ?? 'Usuário'} 👋",
            style: FluentTheme.of(context).typography.title,
          ),
        ),
        children: [
          _buildQuickActions(context, ref, user),
          const SizedBox(height: 32),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, EvaluatorModel? user) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _quickActionButton(
          icon: FluentIcons.people_add,
          label: 'Novo Participante',
          onPressed: () {
            ref
                .read(createParticipantEvaluationProvider.notifier)
                .createParticipantWithEvaluation(
              evaluatorId: user?.evaluatorId ?? 1,
            );
          },
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "🕓 Atividades Recentes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text("Criações recentes aparecerão aqui em breve."),
      ],
    );
  }

  // === FEEDBACK ===
  void _showSuccessInfoBar(
      BuildContext context,
      WidgetRef ref,
      ParticipantEntity? participant,
      ) {
    AppLogger.info('[UI] Participant created successfully.');

    if (participant == null) return;

    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: const Text('Sucesso'),
        content: Text(
          'Participante "${participant.fullName}" e avaliação criados com sucesso!',
        ),
        severity: InfoBarSeverity.success,
        action: IconButton(
          icon: const Icon(FluentIcons.info),
          onPressed: () {
            close();
            _showParticipantDetailsDialog(context, participant);
          },
        ),
      ),
    );
  }

  void _showErrorInfoBar(BuildContext context, String message) {
    AppLogger.warning('[UI] Participant creation failed: $message');
    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: const Text('Erro'),
        content: Text(message),
        severity: InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  Future<void> _showParticipantDetailsDialog(
      BuildContext context,
      ParticipantEntity participant,
      ) async {
    await showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text('Novo Participante Criado'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧍 Nome: ${participant.fullName}'),
            Text('🎂 Nascimento: ${participant.birthDate.toLocal()}'),
            Text('🎓 Educação: ${participant.educationLevel}'),
            const Text('📊 Status da Avaliação: Pendente'),
          ],
        ),
        actions: [
          Button(
            child: const Text('Fechar'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}
