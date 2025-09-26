import 'package:flutter/material.dart';

class AdminRegistrationController {
  final fullNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final specialtyController = TextEditingController();
  final cpfOrNifController = TextEditingController();
  final confirmCpfOrNifController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  void dispose() {
    fullNameController.dispose();
    dateOfBirthController.dispose();
    specialtyController.dispose();
    cpfOrNifController.dispose();
    confirmCpfOrNifController.dispose();
    usernameController.dispose();
    specialtyController.dispose();
    emailController.dispose();
  }
}
