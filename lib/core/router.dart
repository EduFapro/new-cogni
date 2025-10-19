import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/evaluator/presentation/evaluator_registration_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';
import 'logger/app_logger.dart';

final router = GoRouter(
  initialLocation: '/',
  observers: [
    LoggingNavigatorObserver(),
  ],
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) =>
      const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) =>
      const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
      const HomeScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'evaluator_registration',
      builder: (context, state) => const EvaluatorRegistrationScreen(),
    ),
  ],
);

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    AppLogger.nav('PUSHED: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    AppLogger.nav('POPPED: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    AppLogger.nav(
        'REPLACED: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    AppLogger.nav('REMOVED: ${route.settings.name}');
  }
}
