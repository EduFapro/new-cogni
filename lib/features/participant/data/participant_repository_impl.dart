import '../../../core/logger/app_logger.dart';
import '../../participant/domain/participant_entity.dart';
import '../../participant/domain/participant_repository.dart';
import 'participant_local_datasource.dart';
import 'participant_remote_data_source.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  final ParticipantLocalDataSource local;
  final ParticipantRemoteDataSource? remote;

  ParticipantRepositoryImpl({required this.local, this.remote});

  @override
  Future<void> insertParticipant(ParticipantEntity participant) async {
    AppLogger.db(
      'ParticipantRepositoryImpl.insertParticipant → name=${participant.name} ${participant.surname}',
    );

    // 1. Save to local DB (primary operation)
    final db = await local.dbHelper.database;
    await local.insertParticipant(db, participant.toMap());

    // 2. Sync to backend (fire-and-forget)
    if (remote != null && participant.participantID != null) {
      _syncToBackend(() async {
        // Note: In a real scenario, you'd need the evaluatorId
        // For now, we'll skip the backend sync or handle it differently
        AppLogger.info(
          'Participant created locally, backend sync requires evaluatorId context',
        );
      });
    }
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

    // 1. Delete from local DB (primary operation)
    await local.deleteParticipant(id);

    // 2. Sync deletion to backend (fire-and-forget)
    if (remote != null) {
      _syncToBackend(() async {
        final success = await remote!.deleteParticipant(id);
        if (success) {
          AppLogger.info('Participant $id deleted from backend');
        }
      });
    }
  }

  @override
  Future<void> updateParticipant(ParticipantEntity participant) async {
    AppLogger.db(
      'ParticipantRepositoryImpl.updateParticipant → id=${participant.participantID}',
    );

    // 1. Update in local DB (primary operation)
    await local.updateParticipant(participant);

    // 2. Sync update to backend (fire-and-forget)
    if (remote != null && participant.participantID != null) {
      _syncToBackend(() async {
        // Note: Similar issue with evaluatorId
        AppLogger.info(
          'Participant updated locally, backend sync requires evaluatorId context',
        );
      });
    }
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

  // Helper method for fire-and-forget backend sync
  void _syncToBackend(Future<void> Function() syncOperation) {
    syncOperation().catchError((error, stackTrace) {
      AppLogger.error(
        'Backend sync failed (continuing locally)',
        error,
        stackTrace,
      );
      // Don't rethrow - local operation already succeeded
    });
  }
}
