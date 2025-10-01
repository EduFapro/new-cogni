import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/theme/app_colors.dart';
import 'admin_registration_form.dart';

class EvaluatorRegistrationScreen extends StatelessWidget {
  const EvaluatorRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.midnightBlue,
              AppColors.deepSeaBlue,
              AppColors.steelBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const AdminRegistrationForm(),
            ),
          ),
        ),
      ),
    );
  }
}
