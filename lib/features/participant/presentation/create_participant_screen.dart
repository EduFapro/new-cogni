import 'package:fluent_ui/fluent_ui.dart';

import 'create_participant_form.dart';

class CreatePatientScreen extends StatelessWidget {
  const CreatePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Criar Novo Paciente')),
      children: const [
        ParticipantRegistrationForm(),
      ],

    );
  }
}
