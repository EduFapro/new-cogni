import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_registration_provider.dart';

class AdminForm extends ConsumerWidget {
  const AdminForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(adminRegistrationControllerProvider);

    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: controller.fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          TextFormField(
            controller: controller.dateOfBirthController,
            decoration: const InputDecoration(labelText: 'Date of Birth'),
          ),
          TextFormField(
            controller: controller.specialtyController,
            decoration: const InputDecoration(labelText: 'Specialty'),
          ),
          TextFormField(
            controller: controller.cpfOrNifController,
            decoration: const InputDecoration(labelText: 'CPF'),
          ),
          TextFormField(
            controller: controller.confirmCpfOrNifController,
            decoration: const InputDecoration(labelText: 'Confirm CPF'),
          ),
          TextFormField(
            controller: controller.usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            readOnly: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Chamar função de cadastro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário registrado!')),
              );
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}
