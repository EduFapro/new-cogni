import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/evaluator/presentation/create_admin_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/admin/register',
      name: 'admin_register',
      builder: (BuildContext context, GoRouterState state) => const CreateAdminScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
  ],
);


