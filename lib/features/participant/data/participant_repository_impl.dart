import '../../../core/logger/app_logger.dart';
import '../../participant/domain/participant_entity.dart';
import '../../participant/domain/participant_repository.dart';
import 'participant_local_datasource.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  final ParticipantLocalDataSource local;

  ParticipantRepositoryImpl({required this.local});

  @override
  Future<void> insertParticipant(ParticipantEntity participant) async {
    AppLogger.db(
      'ParticipantRepositoryImpl.insertParticipant → name=${participant.name} ${participant.surname}',
    );
    // Uses a DB/txn-aware method in the local data source
    final db = await local.dbHelper.database;
    await local.insertParticipant(db, participant.toMap());
  }

  @override
  Future<List<ParticipantEntity>> getAllParticipants() async {
    AppLogger.db('ParticipantRepositoryImpl.getAllParticipants → fetching');
    final result = await local.getAllParticipants();
    AppLogger.db(
      'ParticipantRepositoryImpl.getAllParticipants → fetched ${result.length} participants',
    );
    return result;
  }

  @override
  Future<ParticipantEntity?> getById(int id) async {
    AppLogger.db('ParticipantRepositoryImpl.getById → id=$id');
    final participant = await local.getById(id);
    if (participant == null) {
      AppLogger.warning('ParticipantRepositoryImpl.getById → not found id=$id');
    }
    return participant;
  }

  @override
  Future<void> deleteParticipant(int id) async {
    AppLogger.db('ParticipantRepositoryImpl.deleteParticipant → id=$id');
    await local.deleteParticipant(id);
  }

  @override
  Future<List<ParticipantEntity>> getParticipantsByEvaluatorId(
    int evaluatorId,
  ) async {
    AppLogger.db(
      'ParticipantRepositoryImpl.getParticipantsByEvaluatorId → evaluatorId=$evaluatorId',
    );
    return local.getParticipantsByEvaluatorId(evaluatorId);
  }
}
