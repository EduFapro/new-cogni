import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/evaluation_entity.dart';

class EvaluationLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  EvaluationLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertEvaluation(DatabaseExecutor txn, Map<String, dynamic> data) async {
    AppLogger.db('Inserting evaluation for participantId=${data['participant_id']}');
    try {
      final id = await txn.insert(Tables.evaluations, data);
      AppLogger.db('Inserted evaluation with ID=$id');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting evaluation', e, s);
      return null;
    }
  }

  Future<List<EvaluationEntity>> getAllEvaluations() async {
    final db = await _db;
    final maps = await db.query(Tables.evaluations);
    return maps.map(EvaluationEntity.fromMap).toList();
  }

  Future<EvaluationEntity?> getById(Database db, int id) async {
    final maps = await db.query(
      Tables.evaluations,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return EvaluationEntity.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
