import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_form.dart';

class AdminRegistrationScreen extends ConsumerWidget {
  const AdminRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Registration')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: AdminForm(),
      ),
    );
  }
}
