import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';
import '../participant/presentation/create_participant_screen.dart';
import '../participant/presentation/participant_list_screen.dart';

import 'home_providers.dart';
import 'backend_status_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeNavigationProvider);

    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('CogniVoice Home'),
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const BackendStatusIndicator(), const SizedBox(width: 16)],
        ),
      ),
      pane: NavigationPane(
        selected: selectedIndex,
        onChanged: (index) => ref
            .read(homeNavigationProvider.notifier)
            .setIndex(index), // ✅ Update provider
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
            body: ParticipantListScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.add_friend),
            title: const Text('Criar Paciente'),
            body: const CreatePatientScreen(),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.sign_out),
            title: const Text('Sair'),
            onTap: () async {
              final repository = await ref.read(authRepositoryProvider.future);
              await repository.signOut();
              ref.read(currentUserProvider.notifier).setUser(null);
              if (context.mounted) context.go('/login');
            },
            body: const SizedBox.shrink(),
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
      children: const [Text('Aqui é o conteúdo principal do dashboard.')],
    );
  }
}

class BackendStatusIndicator extends HookConsumerWidget {
  const BackendStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backendStatusProvider);

    final color = switch (status) {
      BackendStatus.checking => Colors.yellow,
      BackendStatus.connected => Colors.green,
      BackendStatus.disconnected => Colors.red,
    };

    final tooltip = switch (status) {
      BackendStatus.checking => 'Verificando conexão...',
      BackendStatus.connected => 'Conectado ao servidor',
      BackendStatus.disconnected => 'Desconectado (Offline)',
    };

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        onPressed: () {
          ref.read(backendStatusProvider.notifier).checkStatus();
        },
      ),
    );
  }
}
