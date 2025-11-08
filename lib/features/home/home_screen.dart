import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('CogniVoice Home'),
      ),
      pane: NavigationPane(
        selected: 0,
        onChanged: (index) {
          // Optional: Add logic for selected index
        },
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Dashboard'),
            body: const DashboardContent(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('Participantes'),
            body: const ParticipantsPage(), // Replace with real widget
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text('Sair'),
            onTap: () {
              ref.read(currentUserProvider.notifier).setUser(null);
              if (context.mounted) context.go('/login');
            },
            body: const SizedBox.shrink(), // Required, can't be null
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          'Bem-vindo!',
          style: FluentTheme.of(context).typography.title,
        ),
      ),
      children: const [
        Text('Aqui é o conteúdo principal do dashboard.'),
      ],
    );
  }
}

class ParticipantsPage extends StatelessWidget {
  const ParticipantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      content: Text('Lista de participantes (em breve)'),
    );
  }
}
