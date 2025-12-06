import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/logger/app_logger.dart';
import '../../features/evaluator/data/evaluator_local_datasource.dart';
import '../../seeders/seed_runner.dart';
import '../features/auth/data/auth_local_datasource.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/data/datasources/evaluator_remote_datasource.dart';
import '../core/database/prod_database_helper.dart';
import '../core/network.dart';
import '../core/environment.dart';
import '../shared/env/env_helper.dart';
import '../core/utils/file_helper.dart';
import 'providers.dart';

/// The route that the app should navigate to after startup.
final startupProvider = FutureProvider<String>((ref) async {
  AppLogger.info('[STARTUP] Starting application initialization...');

  try {
    // 1. Get Database
    final db = await ProdDatabaseHelper.instance.database;

    // 2. Run Seeding (Idempotent)
    AppLogger.info('[STARTUP] Running database seeder...');
    await SeedRunner().run(db: db);

    // 2.5 Check Backend Mode (Only if NOT offline)
    final env = EnvHelper.currentEnv;
    final network = NetworkService();

    if (env != AppEnv.offline) {
      final status = await network.checkBackendStatus();
      if (status != null) {
        final mode = status['mode'];
        AppLogger.info('🌍 Backend Connected | Mode: $mode');
      } else {
        AppLogger.warning('⚠️ Backend unreachable or sync disabled');
      }
    } else {
      AppLogger.info('📴 Offline Mode: Skipping backend check.');
    }

    // 3. Initialize Data Sources & Repositories
    final evaluatorDS = EvaluatorLocalDataSource(db);
    final authDS = AuthLocalDataSource(db);
    final networkService = NetworkService();
    final remoteDS = EvaluatorRemoteDataSource(networkService);
    final authRepo = AuthRepositoryImpl(authDS, remoteDS, networkService, env);

    // 4. Check for Auto-Login
    AppLogger.info('[STARTUP] Checking for current user...');
    final currentUser = await authRepo.fetchCurrentUserOrNull();

    if (currentUser != null) {
      AppLogger.info('[STARTUP] Auto-login success: ${currentUser.email}');
      // Set token in network service
      if (currentUser.token != null) {
        networkService.setToken(currentUser.token);
      }
      // Update the user provider
      ref.read(currentUserProvider.notifier).setUser(currentUser);
      return '/home';
    }

    // 5. Check for Existing Evaluators
    AppLogger.info('[STARTUP] Checking for existing evaluators...');
    final anyEvaluator = await evaluatorDS.getFirstEvaluator();

    if (anyEvaluator != null) {
      AppLogger.info('[STARTUP] Evaluator exists → go to login');
      return '/login';
    } else {
      AppLogger.info('[STARTUP] No evaluator found → go to registration');
      return '/register';
    }
  } catch (e, stack) {
    AppLogger.error('[STARTUP] Critical error during initialization', e, stack);
    rethrow; // Let the UI handle the error state
  }
});
