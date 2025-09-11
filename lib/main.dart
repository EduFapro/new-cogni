import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';

Future<void> initDatabaseFactory() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabaseFactory();

  runApp(const ProviderScope(child: StartupApp()));
}

class StartupApp extends StatelessWidget {
  const StartupApp({super.key});

  @override
  Widget build(BuildContext context) {
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
