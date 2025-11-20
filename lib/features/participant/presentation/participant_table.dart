import 'package:fluent_ui/fluent_ui.dart';
import '../domain/participant_with_evaluation.dart';

class ParticipantTable extends StatelessWidget {
  final List<ParticipantWithEvaluation> participants;

  const ParticipantTable({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFE8E8E8)),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Status'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Data de Avaliação'),
            ),
          ],
        ),
        ...participants.map((item) {
          return TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFD0D0D0))),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.fullName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.isCompleted ? '✅ Feita' : '⏳ Pendente'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.evaluationDateFormatted),
              ),
            ],
          );
        }),
      ],
    );
  }
}
