import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_providers.dart';
import '../application/login_notifier.dart';
import 'login_form.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.nav('LoginScreen initialized');

    final showInfoBar = useState(false);
    final infoBarMsg = useState('');
    final isSuccess = useState(false);

    ref.listen<AsyncValue<bool>>(loginProvider, (previous, next) {
      next.when(
        data: (success) {
          if (success) {
            AppLogger.nav('Login successful → navigating to /home');
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) context.go('/home');
            });
          }
        },
        error: (err, _) {
          AppLogger.warning('Login error displayed: $err');
          isSuccess.value = false;
          infoBarMsg.value = err.toString();
          showInfoBar.value = true;
        },
        loading: () => AppLogger.debug('Login process loading...'),
      );
    });

    return NavigationView(
      content: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.aquaBlue, AppColors.skyBlue, AppColors.chromeBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(child: LoginForm()),
      ),
    );
  }
}
