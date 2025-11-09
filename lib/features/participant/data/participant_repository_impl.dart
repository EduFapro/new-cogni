import '../../participant/domain/participant_entity.dart';
import '../../participant/domain/participant_repository.dart';
import 'participant_local_datasource.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  final ParticipantLocalDataSource local;

  ParticipantRepositoryImpl({required this.local});

  @override
  Future<void> insertParticipant(ParticipantEntity participant) async {
    final db = await local.dbHelper.database;
    await local.insertParticipant(db, participant.toMap());
  }

  @override
  Future<List<ParticipantEntity>> getAllParticipants() async {
    final db = await local.dbHelper.database;
    return local.getAllParticipants();
  }

  @override
  Future<ParticipantEntity?> getById(int id) async {
    final db = await local.dbHelper.database;
    return local.getById(id);
  }

  @override
  Future<void> deleteParticipant(int id) async {
    final db = await local.dbHelper.database;
    await local.deleteParticipant(db, id);
  }
}
