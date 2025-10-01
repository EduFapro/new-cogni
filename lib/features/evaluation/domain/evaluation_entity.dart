import 'dart:convert';

import '../../../core/constants/enums/progress_status.dart';
import '../data/evaluation_constants.dart';

class EvaluationEntity {
  final int? evaluationID;
  final int evaluatorID;
  final int participantID;
  final EvaluationStatus status;
  final DateTime evaluationDate;
  final int language;

  EvaluationEntity({
    this.evaluationID,
    DateTime? evaluationDate,
    this.status = EvaluationStatus.pending,
    required this.evaluatorID,
    required this.participantID,
    required this.language,
  }) : evaluationDate = evaluationDate ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    EvaluationFields.id: evaluationID,
    EvaluationFields.date: evaluationDate.toIso8601String(),
    EvaluationFields.evaluatorId: evaluatorID,
    EvaluationFields.participantId: participantID,
    EvaluationFields.status: status.numericValue,
    EvaluationFields.language: language,
  };

  static EvaluationEntity fromMap(Map<String, dynamic> map) {
    return EvaluationEntity(
      evaluationID: map[EvaluationFields.id] as int?,
      evaluatorID: map[EvaluationFields.evaluatorId] as int,
      participantID: map[EvaluationFields.participantId] as int,
      language: map[EvaluationFields.language] as int,
      status: EvaluationStatus.fromValue(
        map[EvaluationFields.status] ?? 1,
      ),
      evaluationDate: map[EvaluationFields.date] != null
          ? DateTime.tryParse(map[EvaluationFields.date]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  static EvaluationEntity fromJson(String jsonString) =>
      EvaluationEntity.fromMap(jsonDecode(jsonString));

  @override
  String toString() =>
      'EvaluationEntity(evaluationID: $evaluationID, evaluatorID: $evaluatorID, participantID: $participantID, status: ${status.description})';
}
