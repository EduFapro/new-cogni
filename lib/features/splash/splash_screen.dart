import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the startup provider
    final startupState = ref.watch(startupProvider);

    // Listen for changes to navigate once ready
    ref.listen<AsyncValue<String>>(startupProvider, (previous, next) {
      next.whenData((route) {
        if (context.mounted) {
          context.go(route);
        }
      });
    });

    return NavigationView(
      content: ScaffoldPage(
        content: Center(
          child: startupState.when(
            data: (_) =>
                const SizedBox.shrink(), // Navigation happens in listen
            loading: () => Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ProgressRing(),
                SizedBox(height: 16),
                Text(
                  'Inicializando o aplicativo...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            error: (error, stack) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.error, size: 32, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro ao iniciar: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                Button(
                  child: const Text('Tentar novamente'),
                  onPressed: () => ref.refresh(startupProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
