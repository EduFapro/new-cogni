import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../core/theme/app_colors.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final cpfController = TextEditingController();
  final passwordController = TextEditingController();
  final specialtyController = TextEditingController();


  DateTime? selectedDate;
  bool isLoading = false;

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8080/admin/register"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "name": nameController.text,
        "surname": surnameController.text,
        "birthDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "cpfOrNif": cpfController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "specialty": specialtyController.text,
        "firstLogin": true,
        "isAdmin": true
      }),
    );

    setState(() => isLoading = false);

    final success = response.statusCode == 200;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(success ? "Sucesso" : "Erro"),
        content: Text(success
            ? "✅ Admin registrado com sucesso"
            : "❌ Erro: ${response.body}"),
        actions: [
          FilledButton(
            child: const Text("Ok"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ScaffoldPage(
        header: const PageHeader(title: Text("Registro de Administrador")),
        content: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildTextField("Nome", nameController),
                  _buildTextField("Sobrenome", surnameController),
                  _buildTextField("Usuário", usernameController),
                  _buildTextField("CPF/NIF", cpfController),
                  InfoLabel(
                    label: "Senha",
                    child: PasswordFormBox(
                      controller: passwordController,
                      revealMode: PasswordRevealMode.peekAlways,
                      placeholder: "Digite a senha",
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Digite a senha"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoLabel(
                    label: "Data de Nascimento",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : "Nenhuma data selecionada",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Expander(
                          header: const Text("Selecionar data"),
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: FluentTheme.of(context).micaBackgroundColor,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: SfDateRangePicker(
                              onSelectionChanged: (args) {
                                setState(() {
                                  selectedDate = args.value;
                                });
                              },
                              selectionMode: DateRangePickerSelectionMode.single,
                              initialSelectedDate: selectedDate,
                              showNavigationArrow: true,
                              todayHighlightColor: AppColors.primary,
                              selectionColor: AppColors.primary,
                              backgroundColor: FluentTheme.of(context).micaBackgroundColor,
                              headerStyle: const DateRangePickerHeaderStyle(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                textStyle: const TextStyle(color: Colors.white),
                                todayTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                leadingDatesTextStyle: TextStyle(color: Colors.grey[70]),
                                trailingDatesTextStyle: TextStyle(color: Colors.grey[70]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InfoLabel(
                    label: "Especialidade",
                    child: TextFormBox(
                      controller: specialtyController,
                      placeholder: "Digite sua especialidade",
                      validator: (v) => v == null || v.isEmpty ? "Digite a especialidade" : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 24),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(AppColors.primary),
                      padding: ButtonState.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    onPressed: isLoading ? null : _registerAdmin,
                    child: isLoading
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
