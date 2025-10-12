import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/logger/app_logger.dart';
import '../application/login_notifier.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    void onLoginPressed() {
      final email = emailController.text.trim();
      final password = passwordController.text;
      AppLogger.info('Login button tapped: $email');
      ref.read(loginProvider.notifier).login(email, password);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InfoLabel(label: 'Email', child: TextBox(controller: emailController)),
        const SizedBox(height: 12),
        InfoLabel(label: 'Senha', child: TextBox(controller: passwordController, obscureText: true)),
        const SizedBox(height: 20),
        FilledButton(
          child: const Text('Entrar'),
          onPressed: onLoginPressed,
        ),
      ],
    );
  }
}
