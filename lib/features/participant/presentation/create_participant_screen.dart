import 'package:fluent_ui/fluent_ui.dart';
import '../../../core/logger/app_logger.dart';
import 'create_participant_form.dart';

class CreatePatientScreen extends StatelessWidget {
  const CreatePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.nav('Navigated to CreatePatientScreen');
    return ScaffoldPage.scrollable(
      header: PageHeader(title: Text('Criar Novo Participante')),
      children: [ParticipantRegistrationForm()],
    );
  }
}
