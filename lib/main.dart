import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: StartupApp()));
}

class StartupApp extends StatelessWidget {
  const StartupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Novo Cogni',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      routerConfig: router,
    );
  }
}
