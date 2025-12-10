import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_providers.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final showPassword = useState(false);

    final loginState = ref.watch(loginProvider);
    final showInfoBar = useState(false);
    final infoBarMsg = useState('');
    final isSuccess = useState(false);

    ref.listen<AsyncValue<bool>>(loginProvider, (previous, next) {
      next.when(
        data: (success) {
          if (success) {
            AppLogger.nav('Login successful → navigating to /home');
            isSuccess.value = true;
            infoBarMsg.value = 'Login successful!';
            showInfoBar.value = true;
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) context.go('/home');
            });
          }
        },
        error: (err, _) {
          AppLogger.warning('Login error: $err');
          isSuccess.value = false;
          infoBarMsg.value = err.toString();
          showInfoBar.value = true;
        },
        loading: () {
          AppLogger.debug('Login loading...');
        },
      );
    });

    void onLoginPressed() {
      final email = emailController.text.trim();
      final password = passwordController.text;
      AppLogger.info('Login pressed: $email');
      ref.read(loginProvider.notifier).login(email, password);
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.coolGray900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.softWhite,
              ),
            ),
            const SizedBox(height: 24),

            // Email
            InfoLabel(
              label: "E-mail",
              child: TextBox(
                placeholder: "email@exemplo.com",
                controller: emailController,
              ),
            ),
            const SizedBox(height: 16),

            // Password + visibility toggle
            InfoLabel(
              label: "Senha",
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextBox(
                    controller: passwordController,
                    obscureText: !showPassword.value,
                    placeholder: "Sua senha",
                  ),
                  IconButton(
                    icon: Icon(
                      showPassword.value ? FluentIcons.hide3 : FluentIcons.view,
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Esqueceu a senha?",
                style: TextStyle(
                  color: AppColors.skyBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login button with loading
            FilledButton(
              child: loginState.isLoading
                  ? const ProgressRing()
                  : const Text("Entrar"),
              onPressed: loginState.isLoading ? null : onLoginPressed,
            ),
            const SizedBox(height: 12),

            // 👇 New: Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Não tem uma conta?",
                  style: TextStyle(color: AppColors.softWhite),
                ),
                const SizedBox(width: 6),
                HyperlinkButton(
                  onPressed: () {
                    context.go('/register'); // must match your router
                  },
                  child: const Text(
                    "Criar uma",
                    style: TextStyle(
                      color: AppColors.skyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info bar
            if (showInfoBar.value)
              InfoBar(
                title: Text(isSuccess.value ? "Success" : "Error"),
                content: Text(infoBarMsg.value),
                severity: isSuccess.value
                    ? InfoBarSeverity.success
                    : InfoBarSeverity.error,
                isLong: true,
                onClose: () => showInfoBar.value = false,
              ),
          ],
        ),
      ),
    );
  }
}
