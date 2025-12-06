import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../providers/providers.dart';
import '../../core/utils/file_helper.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanupChecked = useState(false);

    // Initial check for legacy data
    useEffect(() {
      Future<void> checkCleanup() async {
        final needsCleanup = await checkLegacyData();

        if (needsCleanup && context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text(
                'Limpeza de Instalação Anterior',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foi encontrada uma pasta chamada "Cognivoice" na sua pasta de Documentos, possivelmente originada de uma instalação anterior do aplicativo.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ Essa pasta será removida automaticamente para que a nova instalação funcione corretamente.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Se precisar de algum conteúdo dessa pasta, faça um backup manual antes de prosseguir.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  child: const Text('OK, Entendi'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await performLegacyCleanup();
                  },
                ),
                Button(
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(Colors.red.dark),
                  ),
                  child: const Text('Cancelar e Fechar'),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            ),
          );
        }
        cleanupChecked.value = true;
      }

      checkCleanup();
      return null;
    }, []);

    // Only watch startup provider after cleanup check is done
    final startupState = cleanupChecked.value
        ? ref.watch(startupProvider)
        : const AsyncValue.loading();

    // Listen for changes to navigate once ready
    ref.listen<AsyncValue<String>>(startupProvider, (previous, next) {
      if (!cleanupChecked.value) return; // Don't navigate before cleanup check

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
