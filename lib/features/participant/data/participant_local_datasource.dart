import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';
import '../data/participant_constants.dart';
import '../domain/participant_entity.dart';

class ParticipantLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  ParticipantLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertParticipant(
    DatabaseExecutor txn,
    Map<String, dynamic> data,
  ) async {
    // Make a mutable copy so we don't mutate caller's map.
    final payload = Map<String, dynamic>.from(data);

    // Normalize enums / types to what SQLite understands.

    // laterality: required, stored as int
    if (payload.containsKey(ParticipantFields.laterality)) {
      final value = payload[ParticipantFields.laterality];
      if (value is Laterality) {
        payload[ParticipantFields.laterality] = value.numericValue;
      }
    } else {
      // Fallback for legacy tests/callers that didn't set laterality.
      // Pick a sensible default (or change to whatever your domain expects).
      payload[ParticipantFields.laterality] =
          Laterality.ambidextrous.numericValue;
    }

    // sex may be passed as enum or int
    if (payload[ParticipantFields.sex] is Sex) {
      payload[ParticipantFields.sex] =
          (payload[ParticipantFields.sex] as Sex).numericValue;
    }

    // education_level may be passed as enum or int
    if (payload[ParticipantFields.educationLevel] is EducationLevel) {
      payload[ParticipantFields.educationLevel] =
          (payload[ParticipantFields.educationLevel] as EducationLevel)
              .numericValue;
    }

    AppLogger.db(
      'ParticipantLocalDataSource.insertParticipant → name=${payload[ParticipantFields.name]}',
    );

    try {
      final id = await txn.insert(Tables.participants, payload);
      AppLogger.db(
        'ParticipantLocalDataSource.insertParticipant → inserted with ID=$id',
      );
      return id;
    } catch (e, s) {
      AppLogger.error(
        'ParticipantLocalDataSource.insertParticipant → error inserting participant',
        e,
        s,
      );
      return null;
    }
  }

  Future<List<ParticipantEntity>> getAllParticipants() async {
    AppLogger.db('ParticipantLocalDataSource.getAllParticipants → querying DB');
    final db = await _db;
    final maps = await db.query(Tables.participants);
    final participants = maps.map((map) {
      return ParticipantEntity.fromMap(map);
    }).toList();

    AppLogger.db(
      'ParticipantLocalDataSource.getAllParticipants → mapped ${participants.length} participants',
    );
    return participants;
  }

  Future<ParticipantEntity?> getById(int id) async {
    AppLogger.db('ParticipantLocalDataSource.getById → id=$id');
    final db = await _db;
    final result = await db.query(
      Tables.participants,
      where: '${ParticipantFields.id} = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      AppLogger.warning(
        'ParticipantLocalDataSource.getById → no participant found for id=$id',
      );
      return null;
    }

    final participant = ParticipantEntity.fromMap(result.first);
    AppLogger.db(
      'ParticipantLocalDataSource.getById → found participant id=$id',
    );
    return participant;
  }

  Future<void> deleteParticipant(int id) async {
    AppLogger.db('ParticipantLocalDataSource.deleteParticipant → id=$id');
    final db = await _db;
    try {
      final count = await db.delete(
        Tables.participants,
        where: '${ParticipantFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db(
        'ParticipantLocalDataSource.deleteParticipant → affected rows=$count for id=$id',
      );
    } catch (e, s) {
      AppLogger.error(
        'ParticipantLocalDataSource.deleteParticipant → error deleting id=$id',
        e,
        s,
      );
    }
  }

  Future<void> updateParticipant(ParticipantEntity participant) async {
    AppLogger.db(
      'ParticipantLocalDataSource.updateParticipant → id=${participant.participantID}',
    );
    final db = await _db;

    final payload = Map<String, dynamic>.from(participant.toMap());

    // Normalize enums to numeric values
    if (payload[ParticipantFields.sex] is Sex) {
      payload[ParticipantFields.sex] =
          (payload[ParticipantFields.sex] as Sex).numericValue;
    }

    if (payload[ParticipantFields.educationLevel] is EducationLevel) {
      payload[ParticipantFields.educationLevel] =
          (payload[ParticipantFields.educationLevel] as EducationLevel)
              .numericValue;
    }

    if (payload[ParticipantFields.laterality] is Laterality) {
      payload[ParticipantFields.laterality] =
          (payload[ParticipantFields.laterality] as Laterality).numericValue;
    }

    try {
      final count = await db.update(
        Tables.participants,
        payload,
        where: '${ParticipantFields.id} = ?',
        whereArgs: [participant.participantID],
      );
      AppLogger.db(
        'ParticipantLocalDataSource.updateParticipant → updated $count rows',
      );
    } catch (e, s) {
      AppLogger.error(
        'ParticipantLocalDataSource.updateParticipant → error updating id=${participant.participantID}',
        e,
        s,
      );
    }
  }

  Future<List<ParticipantEntity>> getParticipantsByEvaluatorId(
    int evaluatorId,
  ) async {
    AppLogger.db(
      'ParticipantLocalDataSource.getParticipantsByEvaluatorId → evaluatorId=$evaluatorId',
    );
    final db = await _db;

    // Join participants and evaluations to filter by evaluator_id
    final query =
        '''
      SELECT p.* 
      FROM ${Tables.participants} p
      INNER JOIN ${Tables.evaluations} e ON p.${ParticipantFields.id} = e.participant_id
      WHERE e.evaluator_id = ?
    ''';

    final maps = await db.rawQuery(query, [evaluatorId]);
    final participants = maps.map((map) {
      return ParticipantEntity.fromMap(map);
    }).toList();

    AppLogger.db(
      'ParticipantLocalDataSource.getParticipantsByEvaluatorId → found ${participants.length} participants',
    );
    return participants;
  }
}
