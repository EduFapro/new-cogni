import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../../core/database_helper.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';
import '../../features/evaluator/data/evaluator_model.dart';
import '../../seeders/seed_runner.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize app safely after the first frame
    Future.microtask(() => _initializeApp(context));

    return NavigationView(
      content: ScaffoldPage(
        content: Center(
          child: Column(
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
        ),
      ),
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    try {
      AppLogger.seed('[SPLASH] Starting database seeding...');
      await SeedRunner().run();

      final db = await DatabaseHelper.instance.database;
      final ds = EvaluatorLocalDataSource(db);

      final EvaluatorModel? evaluator = await ds.getFirstEvaluator();

      if (evaluator != null) {
        AppLogger.seed('[SPLASH] Found evaluator: ${evaluator.email}');
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) context.go('/login');
      } else {
        AppLogger.seed('[SPLASH] No evaluator found — going to registration.');
        context.go('/register');
      }
    } catch (e, s) {
      AppLogger.error('[SPLASH] Error during initialization', e, s);
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text('Erro ao iniciar'),
        content: Text(message),
        actions: [
          Button(
            child: const Text('Fechar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
