import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/logger/app_logger.dart';
import 'shared/encryption/deterministic_encryption_helper.dart';

Future<void> initDatabaseFactory() async {
  AppLogger.info('Initializing database factory...');
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  AppLogger.info('✅ Database factory initialized using FFI');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Flutter bindings initialized');
  // 🔗 Connect helper to Flutter logger (debug-only inside AppLogger)
  DeterministicEncryptionHelper.configureLogger(
    info: AppLogger.info,
    error: AppLogger.error,
  );

  // 🔥 Register Flutter logger for encryption helper
  DeterministicEncryptionHelper.configureLogger(
    info: AppLogger.info,
    error: AppLogger.error,
  );

  await initDatabaseFactory();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter framework error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught async error', error, stack);
    return true;
  };

  AppLogger.info('🚀 Application starting...');
  runApp(const ProviderScope(child: StartupApp()));
}

class StartupApp extends StatelessWidget {
  const StartupApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.info('🏗️ Building StartupApp widget tree');
    return FluentApp.router(
      title: 'Novo Cogni',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
