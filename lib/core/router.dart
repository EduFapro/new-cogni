import 'package:fluent_ui/fluent_ui.dart'; // ✅ FluentApp lives here
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin_registration/admin_registration_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_controller.dart';
import '../features/welcome/welcome_screen.dart';




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
    GoRoute(
      path: '/admin/register',
      builder: (context, state) => const AdminRegistrationScreen(),
    ),
  ],
);
