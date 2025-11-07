import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/logger/app_logger.dart';
import 'package:segundo_cogni/features/participant/domain/participant_entity.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ParticipantLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  ParticipantLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertParticipant(
      DatabaseExecutor txn,
      Map<String, dynamic> data,
      ) async {
    AppLogger.db('Inserting participant: ${data['name']}');
    try {
      final id = await txn.insert(Tables.participants, data);
      AppLogger.db('Inserted participant with ID=$id');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting participant', e, s);
      return null;
    }
  }

  Future<List<ParticipantEntity>> getAllParticipants() async {
    final db = await _db;
    final maps = await db.query(Tables.participants);
    return maps.map(ParticipantEntity.fromMap).toList();
  }

  Future<ParticipantEntity?> getById(int id) async {
    final db = await _db;
    final result = await db.query(
      Tables.participants,
      where: 'participant_id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? ParticipantEntity.fromMap(result.first) : null;
  }
}
