import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/evaluator_registration_data.dart';
import 'evaluator_registration_provider.dart';

class EvaluatorRegistrationForm extends HookConsumerWidget {
  const EvaluatorRegistrationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.nav('Opened EvaluatorRegistrationForm');

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final usernameController = useTextEditingController();
    final cpfController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final specialtyController = useTextEditingController();

    final selectedDate = useState<DateTime?>(null);
    final showPassword = useState(false);
    final showConfirmPassword = useState(false);
    final manualUsername = useState(false);
    final isDateExpanded = useState(false);
    final isRedirecting = useState(false);

    final state = ref.watch(evaluatorRegistrationProvider);
    final notifier = ref.read(evaluatorRegistrationProvider.notifier);

    // auto-generate username
    useEffect(() {
      void listener() {
        if (!manualUsername.value) {
          final name = nameController.text.trim();
          final surname = surnameController.text.trim();
          if (name.isNotEmpty && surname.isNotEmpty) {
            usernameController.text =
            "${name.toLowerCase()}_${surname.toLowerCase()}";
          } else {
            usernameController.clear();
          }
        }
      }

      nameController.addListener(listener);
      surnameController.addListener(listener);
      return () {
        nameController.removeListener(listener);
        surnameController.removeListener(listener);
      };
    }, [manualUsername.value]);

    // Listen for registration result
    ref.listen<AsyncValue<EvaluatorRegistrationState>>(
      evaluatorRegistrationProvider,
          (prev, next) {
        next.whenData((value) async {
          if (value == EvaluatorRegistrationState.success) {
            AppLogger.info('Evaluator registered successfully — redirecting');
            isRedirecting.value = true;

            displayInfoBar(
              context,
              builder: (ctx, close) => InfoBar(
                title: const Text("Avaliador registrado!"),
                content:
                const Text("Você será redirecionado para o home!"),
                severity: InfoBarSeverity.success,
                isLong: true,
                onClose: close,
              ),
            );

            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              AppLogger.nav('Navigating to /home after registration');
              context.go('/login');
            }
          }
        });
      },
    );

    Future<void> _submit() async {
      if (!formKey.currentState!.validate() || selectedDate.value == null) {
        AppLogger.warning('Registration form validation failed');
        return;
      }

      final data = EvaluatorRegistrationData(
        name: nameController.text,
        surname: surnameController.text,
        email: emailController.text,
        birthDate: DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        cpf: cpfController.text,
        username: usernameController.text,
        password: passwordController.text,
        specialty: specialtyController.text,
        isAdmin: false,
      );

      AppLogger.info('Submitting evaluator registration for ${data.email}');
      await notifier.registerEvaluator(data);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              "Registro de Administrador",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.softWhite,
              ),
            ),
            const SizedBox(height: 24),

            // name + surname
            Row(
              children: [
                Expanded(child: _buildTextField("Nome", nameController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Sobrenome", surnameController)),
              ],
            ),

            // email + cpf
            Row(
              children: [
                Expanded(child: _buildTextField("Email", emailController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("CPF/NIF", cpfController)),
              ],
            ),

            // username + checkbox
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Usuário",
                      child: TextFormBox(
                        controller: usernameController,
                        enabled: manualUsername.value,
                        validator: (v) =>
                        v!.isEmpty ? "Campo obrigatório" : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Checkbox(
                      content: const Text("Definir usuário manualmente"),
                      checked: manualUsername.value,
                      onChanged: (v) {
                        manualUsername.value = v ?? false;
                        AppLogger.debug(
                            'Manual username mode: ${manualUsername.value}');
                      },
                    ),
                  ),
                ],
              ),
            ),

            // password + confirm password
            Row(
              children: [
                Expanded(
                  child: _buildPasswordField(
                    "Senha",
                    passwordController,
                    showPassword,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPasswordField(
                    "Confirmar Senha",
                    confirmPasswordController,
                    showConfirmPassword,
                    confirm: passwordController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // date picker
            InfoLabel(
              label: "Data de Nascimento",
              child: Expander(
                key: ValueKey(isDateExpanded.value),
                initiallyExpanded: isDateExpanded.value,
                onStateChanged: (open) =>
                isDateExpanded.value = open,
                header: Text(
                  selectedDate.value != null
                      ? DateFormat('dd/MM/yyyy')
                      .format(selectedDate.value!)
                      : "Selecionar data",
                ),
                content: SfDateRangePicker(
                  onSelectionChanged: (args) {
                    selectedDate.value = args.value;
                    isDateExpanded.value = false;
                    AppLogger.debug(
                        'Selected birth date: ${selectedDate.value}');
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: selectedDate.value,
                  showNavigationArrow: true,
                  todayHighlightColor: AppColors.primary,
                  selectionColor: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildTextField("Especialidade", specialtyController),
            const SizedBox(height: 24),

            FilledButton(
              style: ButtonStyle(
                backgroundColor: ButtonState.all(AppColors.primary),
              ),
              onPressed: state.isLoading || isRedirecting.value ? null : _submit,
              child: (state.isLoading || isRedirecting.value)
                  ? const ProgressRing()
                  : const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoLabel(
        label: label,
        child: TextFormBox(
          controller: controller,
          validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      ValueNotifier<bool> show, {TextEditingController? confirm}) {
    return InfoLabel(
      label: label,
      child: TextFormBox(
        controller: controller,
        obscureText: !show.value,
        placeholder: label == "Senha"
            ? "Digite a senha"
            : "Repita a senha",
        validator: (v) {
          if (v == null || v.isEmpty) return "Campo obrigatório";
          if (label == "Confirmar Senha" &&
              v != confirm?.text) {
            return "As senhas não coincidem";
          }
          if (label == "Senha" && v.length < 6) {
            return "Mínimo 6 caracteres";
          }
          return null;
        },
        suffix: IconButton(
          icon: Icon(show.value
              ? FluentIcons.hide3
              : FluentIcons.view),
          onPressed: () => show.value = !show.value,
        ),
      ),
    );
  }
}
