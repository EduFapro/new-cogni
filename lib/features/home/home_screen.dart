import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';
import '../participant/presentation/providers/create_participant_evaluation_provider.dart';
import '../evaluator/data/evaluator_model.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EvaluatorModel? user = ref.watch(currentUserProvider);
    final createParticipant = ref.watch(createParticipantEvaluationProvider);

    // 🎯 Listen for async state changes (success / error)
    ref.listen(createParticipantEvaluationProvider, (_, next) {
      next.whenOrNull(
        data: (_) => _showInfoBar(
          context,
          'Sucesso',
          'Participante e avaliação criados!',
          InfoBarSeverity.success,
        ),
        error: (e, s) => _showInfoBar(
          context,
          'Erro',
          'Falha ao criar participante: $e',
          InfoBarSeverity.error,
        ),
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

  /// ✅ InfoBar helper
  void _showInfoBar(BuildContext context, String title, String message, InfoBarSeverity severity) {
    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(title),
        content: Text(message),
        severity: severity,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  /// ✅ Quick actions section
  Widget _buildQuickActions(BuildContext context, WidgetRef ref, EvaluatorModel? user) {
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
              evaluatorId: user?.evaluatorId ?? 1, // fallback to dummy
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
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// ✅ Placeholder until evaluation history is implemented
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "🕓 Atividades Recentes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text("Criação de participantes será exibida aqui futuramente."),
      ],
    );
  }
}
