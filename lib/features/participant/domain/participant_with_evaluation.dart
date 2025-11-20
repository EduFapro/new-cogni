import '../../../core/constants/enums/progress_status.dart';
import '../domain/participant_entity.dart';
import '../../evaluation/domain/evaluation_entity.dart';
import 'package:intl/intl.dart';

class ParticipantWithEvaluation {
  final ParticipantEntity participant;
  final EvaluationEntity? evaluation;

  const ParticipantWithEvaluation(this.participant, this.evaluation);

  bool get isCompleted => evaluation?.status == EvaluationStatus.completed;
  bool get isPending => evaluation?.status == EvaluationStatus.pending;
  bool get isInProgress => evaluation?.status == EvaluationStatus.inProgress;

  bool get isOverdue {
    if (evaluation == null) return false;
    final deadline = DateTime.now().subtract(const Duration(days: 7));
    return evaluation!.evaluationDate.isBefore(deadline) && !isCompleted;
  }

  String get fullName => '${participant.name} ${participant.surname}';

  String get evaluationDateFormatted =>
      evaluation != null ? DateFormat('dd/MM/yyyy').format(evaluation!.evaluationDate) : '—';

  String get statusLabel {
    if (evaluation == null) return '❌ Não iniciada';
    switch (evaluation!.status) {
      case EvaluationStatus.completed:
        return '✅ Concluída';
      case EvaluationStatus.pending:
        return '⏳ Pendente';
      case EvaluationStatus.inProgress:
        return '🛠️ Em andamento';
    }
  }
}
