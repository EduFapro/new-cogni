import '../../../core/constants/database_constants.dart';
import '../../evaluator/data/evaluator_constants.dart';
import '../../participant/data/participant_constants.dart';

class EvaluationFields {
    static const id = "evaluation_id";
    static const date = "evaluation_date";
    static const evaluatorId = "evaluator_id"; // FK
    static const participantId = "participant_id"; // FK
    static const status = "status";
    static const language = "language";

    static const all = [
        id,
        date,
        evaluatorId,
        participantId,
        status,
        language,
    ];
}

const scriptCreateTableEvaluations = '''
CREATE TABLE ${Tables.evaluations} (
  ${EvaluationFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${EvaluationFields.date} TIMESTAMP NOT NULL,
  ${EvaluationFields.evaluatorId} INTEGER NOT NULL,
  ${EvaluationFields.participantId} INTEGER UNIQUE NOT NULL,
  ${EvaluationFields.status} INT CHECK(${EvaluationFields.status} >= 0 AND ${EvaluationFields.status} <= 3) NOT NULL,
  ${EvaluationFields.language} INT CHECK(${EvaluationFields.language} >= 1 AND ${EvaluationFields.language} <= 3),
  FOREIGN KEY (${EvaluationFields.evaluatorId}) REFERENCES ${Tables.evaluators}(${EvaluatorFields.id}),
  FOREIGN KEY (${EvaluationFields.participantId}) REFERENCES ${Tables.participants}(${ParticipantFields.id})
);
''';
