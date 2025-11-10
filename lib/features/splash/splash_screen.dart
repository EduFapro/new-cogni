import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../../core/database_helper.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';
import '../../seeders/seed_runner.dart';
import '../auth/data/auth_local_datasource.dart';
import '../auth/data/auth_repository_impl.dart';
import '../../providers/providers.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      if (!context.mounted) return; // 🔐 Ensure still mounted before async logic
      await _initializeApp(context, ref);
    });

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

  Future<void> _initializeApp(BuildContext context, WidgetRef ref) async {
    try {
      AppLogger.seed('[SPLASH] Starting database seeding...');
      final db = await DatabaseHelper.instance.database;
      await SeedRunner().run(db: db);

      final evaluatorDataSource = EvaluatorLocalDataSource(db);
      final auth = AuthLocalDataSource(db);
      final repository = AuthRepositoryImpl(auth);

      final currentUser = await repository.fetchCurrentUserOrNull();

      if (!context.mounted) return; // ✅ Prevent context usage after unmount

      if (currentUser != null) {
        AppLogger.seed('[SPLASH] Auto-login success: ${currentUser.email}');
        ref.read(currentUserProvider.notifier).setUser(currentUser);
        context.go('/home');
        return;
      }

      final anyEvaluator = await evaluatorDataSource.getFirstEvaluator();

      if (!context.mounted) return;

      if (anyEvaluator != null) {
        AppLogger.seed('[SPLASH] Evaluator exists → go to login');
        context.go('/login');
      } else {
        AppLogger.seed('[SPLASH] No evaluator found → go to registration');
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
