import '../../../core/constants/enums/progress_status.dart';
import '../domain/participant_entity.dart';
import '../../evaluation/domain/evaluation_entity.dart';
import 'package:intl/intl.dart';

class ParticipantWithEvaluation {
  final ParticipantEntity participant;
  final EvaluationEntity? evaluation;

  const ParticipantWithEvaluation(this.participant, this.evaluation);

  bool get completed => evaluation?.status == EvaluationStatus.completed;

  String get fullName => '${participant.name} ${participant.surname}';

  String get evaluationDateFormatted =>
      evaluation != null ? DateFormat('dd/MM/yyyy').format(evaluation!.evaluationDate) : '—';
}
