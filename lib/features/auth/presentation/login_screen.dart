import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/login_notifier.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final loginState = ref.watch(loginProvider);

    final showInfoBar = useState(false);
    final infoBarMsg = useState('');
    final isSuccess = useState(false);

    ref.listen<AsyncValue<bool>>(loginProvider, (previous, next) {
      next.when(
        data: (success) {
          if (success) {
            isSuccess.value = true;
            infoBarMsg.value = "Login efetuado com sucesso!";
            showInfoBar.value = true;

            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                context.go('/home');
              }
            });
          }
        },
        error: (err, _) {
          isSuccess.value = false;
          infoBarMsg.value = err.toString();
          showInfoBar.value = true;
        },
        loading: () {},
      );
    });

    return NavigationView(
      content: ScaffoldPage(
        content: Center(
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
                InfoLabel(
                  label: "Email",
                  child: TextBox(
                    placeholder: "you@example.com",
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: "Password",
                  child: PasswordBox(
                    controller: passwordController,
                    placeholder: "********",
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: AppColors.skyBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  child: loginState.isLoading
                      ? const ProgressRing()
                      : const Text("Sign in"),
                  onPressed: loginState.isLoading
                      ? null
                      : () {
                    ref
                        .read(loginProvider.notifier)
                        .login(emailController.text, passwordController.text);
                  },
                ),
                const SizedBox(height: 16),
                if (showInfoBar.value)
                  InfoBar(
                    title: Text(isSuccess.value ? "Sucesso" : "Erro"),
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
        ),
      ),
    );
  }
}
