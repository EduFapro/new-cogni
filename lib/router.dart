import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/welcome/welcome_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
  ],
);
