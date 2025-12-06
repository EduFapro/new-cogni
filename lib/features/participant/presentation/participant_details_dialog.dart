import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../domain/participant_entity.dart';

class ParticipantDetailsDialog extends StatelessWidget {
  final ParticipantEntity participant;

  const ParticipantDetailsDialog({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Dados do Participante'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nome', participant.name),
            _buildDetailRow('Sobrenome', participant.surname),
            _buildDetailRow(
              'Data de Nascimento',
              DateFormat('dd/MM/yyyy').format(participant.birthDate),
            ),
            _buildDetailRow('Sexo', participant.sex.label),
            _buildDetailRow(
              'Nível de Educação',
              participant.educationLevel.label,
            ),
            _buildDetailRow('Lateralidade', participant.laterality.label),
          ],
        ),
      ),
      actions: [
        FilledButton(
          child: const Text('Fechar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
