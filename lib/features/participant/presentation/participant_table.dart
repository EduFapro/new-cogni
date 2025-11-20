import 'package:fluent_ui/fluent_ui.dart';
import '../../../core/theme/app_colors.dart';
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
        2: FlexColumnWidth(4),
      },
      children: [
        // ✅ HEADER row
        const TableRow(
          decoration: BoxDecoration(color: AppColors.indigoBlue),
          children: [
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
              child: Text('Ações'),
            ),
          ],
        ),

        // ✅ DATA rows
        ...participants.map((item) {
          return TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.coolGray500)),
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
                child: Wrap(
                  spacing: 4,
                  children: [
                    Button(
                      child: Text(
                        'Mais Informações',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // TODO: Info logic
                      },
                    ),
                    Button(
                      child: Text(
                        'Prosseguir com Avaliação',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // TODO: Proceed logic
                      },
                    ),
                    Button(
                      child: Text(
                        'Editar Informações',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // TODO: Edit logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}


