import 'participant_entity.dart';

abstract class ParticipantRepository {
  Future<void> insertParticipant(ParticipantEntity participant);
  Future<List<ParticipantEntity>> getAllParticipants();
  Future<ParticipantEntity?> getById(int id);
  Future<void> deleteParticipant(int id);
  Future<void> updateParticipant(ParticipantEntity participant);
  Future<List<ParticipantEntity>> getParticipantsByEvaluatorId(int evaluatorId);
}
