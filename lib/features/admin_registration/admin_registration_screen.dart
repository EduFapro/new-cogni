import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/theme/app_colors.dart';
import 'admin_registration_provider.dart';

class AdminRegistrationScreen extends HookConsumerWidget {
  const AdminRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final surnameController = useTextEditingController();
    final emailController = useTextEditingController();
    final usernameController = useTextEditingController();
    final cpfController = useTextEditingController();
    final passwordController = useTextEditingController();
    final specialtyController = useTextEditingController();
    final selectedDate = useState<DateTime?>(null);

    final state = ref.watch(adminRegistrationProvider);
    final notifier = ref.read(adminRegistrationProvider.notifier);

    Future<void> _submit() async {
      if (!formKey.currentState!.validate() || selectedDate.value == null) return;

      await notifier.registerAdmin({
        "name": nameController.text,
        "surname": surnameController.text,
        "email": emailController.text,
        "birthDate": DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        "cpfOrNif": cpfController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "specialty": specialtyController.text,
        "firstLogin": true,
        "isAdmin": true,
      });

      if (ref.read(adminRegistrationProvider) == AdminRegistrationState.success) {
        showDialog(
          context: context,
          builder: (context) => const ContentDialog(
            title: Text("Sucesso"),
            content: Text("✅ Admin registrado com sucesso"),
          ),
        );
      }
    }

    return NavigationView(
      content: ScaffoldPage(
        header: const PageHeader(title: Text("Registro de Administrador")),
        content: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildTextField("Nome", nameController),
                  _buildTextField("Sobrenome", surnameController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Usuário", usernameController),
                  _buildTextField("CPF/NIF", cpfController),
                  InfoLabel(
                    label: "Senha",
                    child: PasswordFormBox(
                      controller: passwordController,
                      revealMode: PasswordRevealMode.peekAlways,
                      placeholder: "Digite a senha",
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Digite a senha" : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoLabel(
                    label: "Data de Nascimento",
                    child: Expander(
                      header: Text(
                        selectedDate.value != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate.value!)
                            : "Selecionar data",
                      ),
                      content: SfDateRangePicker(
                        onSelectionChanged: (args) {
                          selectedDate.value = args.value;
                        },
                        selectionMode: DateRangePickerSelectionMode.single,
                        initialSelectedDate: selectedDate.value,
                        showNavigationArrow: true,
                        todayHighlightColor: AppColors.primary,
                        selectionColor: AppColors.primary,
                      ),
                    ),
                  ),
                  _buildTextField("Especialidade", specialtyController),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(AppColors.primary),
                    ),
                    onPressed: state == AdminRegistrationState.loading
                        ? null
                        : _submit,
                    child: state == AdminRegistrationState.loading
                        ? const ProgressRing()
                        : const Text("Registrar"),
                  ),
                ],
              ),
            ),
          ),
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
}
