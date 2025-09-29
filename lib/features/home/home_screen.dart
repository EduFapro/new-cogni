import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = 'Eduardo';
    final today = DateTime.now();

    return NavigationView(
      content: ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            "Bem-vindo, $userName 👋",
            style: FluentTheme.of(context).typography.title,
          ),
        ),
        children: [
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildPinnedProjects(),
          const SizedBox(height: 32),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _quickActionButton(
          icon: FluentIcons.add,
          label: 'Novo Projeto',
          onPressed: () {},
        ),
        _quickActionButton(
          icon: FluentIcons.people_add,
          label: 'Novo Avaliador',
          onPressed: () {},
        ),
        _quickActionButton(
          icon: FluentIcons.settings,
          label: 'Configurações',
          onPressed: () {},
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
      style: ButtonStyle(
        padding: ButtonState.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        backgroundColor: ButtonState.all(Colors.blue),
      ),
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


  Widget _buildPinnedProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📌 Projetos Fixados",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(3, (index) {
            return Card(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 200,
                height: 100,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projeto ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Avaliações rápidas para acompanhamento.'),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🕓 Atividades Recentes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InfoLabel(
          label: 'Filtrar',
          child: ComboBox<String>(
            items: const [
              ComboBoxItem(value: 'Hoje', child: Text('Hoje')),
              ComboBoxItem(value: 'Esta Semana', child: Text('Esta Semana')),
              ComboBoxItem(value: 'Este Mês', child: Text('Este Mês')),
            ],
            onChanged: (v) {},
            value: 'Hoje',
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile.selectable(
              title: Text("Avaliação ${index + 1}"),
              subtitle: Text("Concluído por João em 29/09/2025"),
              leading: const Icon(FluentIcons.check_mark),
              onPressed: () {},
            ),
          );
        }),
      ],
    );
  }
}
