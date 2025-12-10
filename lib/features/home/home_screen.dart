import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';
import '../participant/presentation/create_participant_screen.dart';
import '../participant/presentation/participant_list_screen.dart';
import '../auth/presentation/change_password_dialog.dart';

import 'home_providers.dart';
import 'backend_status_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeNavigationProvider);

    return NavigationView(
      // appBar: NavigationAppBar(
      //   title: const Text('Início CogniVoice'),
      //   actions: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [const SizedBox(width: 16)],
      //   ),
      // ),
      pane: NavigationPane(
        selected: selectedIndex,
        onChanged: (index) => ref
            .read(homeNavigationProvider.notifier)
            .setIndex(index), // ✅ Update provider
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Painel'),
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
            icon: const Icon(FluentIcons.lock),
            title: const Text('Alterar Senha'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangePasswordDialog(),
              );
            },
            body: const SizedBox.shrink(),
          ),
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
      children: const [
        BackendStatusCard(),
        // SizedBox(height: 24),
        // Text('Aqui é o conteúdo principal do dashboard.'),
      ],
    );
  }
}

class BackendStatusCard extends HookConsumerWidget {
  const BackendStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backendStatusProvider);

    final color = switch (status) {
      BackendStatus.checking => Colors.yellow,
      BackendStatus.connected => Colors.green,
      BackendStatus.disconnected => Colors.red,
    };

    final icon = switch (status) {
      BackendStatus.checking => FluentIcons.sync,
      BackendStatus.connected => FluentIcons.plug_connected,
      BackendStatus.disconnected => FluentIcons.plug_disconnected,
    };

    final title = switch (status) {
      BackendStatus.checking => 'Verificando conexão...',
      BackendStatus.connected => 'Conectado ao Servidor',
      BackendStatus.disconnected => 'Desconectado',
    };

    final subtitle = switch (status) {
      BackendStatus.checking => 'Aguarde enquanto testamos a conexão.',
      BackendStatus.connected => 'Sincronização de dados ativa.',
      BackendStatus.disconnected => 'Verifique sua internet ou o servidor.',
    };

    return Card(
      backgroundColor: color.withOpacity(0.1),
      borderColor: color.withOpacity(0.5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FluentTheme.of(
                    context,
                  ).typography.bodyStrong?.copyWith(color: color),
                ),
                Text(
                  subtitle,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ],
            ),
          ),
          Button(
            onPressed: () {
              ref.read(backendStatusProvider.notifier).checkStatus();
            },
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }
}
