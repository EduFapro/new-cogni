import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluent_ui/fluent_ui.dart';

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

  bool isLoading = false;

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8080/admin/register"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "name": nameController.text,
        "surname": surnameController.text,
        "birthDate": "1990-01-01", // TODO: usar DatePicker
        "specialty": "Neuropsicologia",
        "cpfOrNif": cpfController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "firstLogin": true,
        "isAdmin": true
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) =>
            ContentDialog(
              title: const Text("Sucesso"),
              content: const Text("✅ Admin registrado com sucesso"),
              actions: [
                FilledButton(
                  child: const Text("Ok"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            ContentDialog(
              title: const Text("Erro"),
              content: Text("❌ Erro: ${response.body}"),
              actions: [
                Button(
                  child: const Text("Fechar"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }
    @override
    Widget build(BuildContext context) {
      return NavigationView(
        content: ScaffoldPage(
          header: const PageHeader(title: Text("Registro de Administrador")),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                InfoLabel(
                  label: "Nome",
                  child: TextFormBox(
                    controller: nameController,
                    validator: (v) => v!.isEmpty ? "Digite o nome" : null,
                  ),
                ),
                InfoLabel(
                  label: "Sobrenome",
                  child: TextFormBox(
                    controller: surnameController,
                    validator: (v) => v!.isEmpty ? "Digite o sobrenome" : null,
                  ),
                ),
                InfoLabel(
                  label: "Usuário",
                  child: TextFormBox(
                    controller: usernameController,
                    validator: (v) => v!.isEmpty ? "Digite o usuário" : null,
                  ),
                ),
                InfoLabel(
                  label: "CPF/NIF",
                  child: TextFormBox(
                    controller: cpfController,
                    validator: (v) => v!.isEmpty ? "Digite o CPF/NIF" : null,
                  ),
                ),
                InfoLabel(
                  label: "Senha",
                  child: PasswordFormBox(
                    controller: passwordController,
                    revealMode: PasswordRevealMode.peekAlways,
                    placeholder: "Digite a senha",
                    validator: (v) => v == null || v.isEmpty ? "Digite a senha" : null,
                  ),
                ),


                const SizedBox(height: 16),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                  ),
                  onPressed: isLoading ? null : _registerAdmin,
                  child: isLoading
                      ? const ProgressRing()
                      : const Text("Registrar"),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
