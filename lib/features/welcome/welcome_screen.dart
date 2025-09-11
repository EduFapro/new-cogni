import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Novo Cogni", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            Text("Your cognitive evaluation companion."),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text("Get Started"),
            )
          ],
        ),
      ),
    );
  }
}
