import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database/base_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../domain/evaluation_entity.dart';
import '../data/evaluation_constants.dart';

class EvaluationLocalDataSource {
  final BaseDatabaseHelper dbHelper;

  EvaluationLocalDataSource({required this.dbHelper});

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertEvaluation(Transaction txn, Map<String, dynamic> data) async {
    try {
      final id = await txn.insert(Tables.evaluations, data); // ✅ use txn
      AppLogger.db('Inserted evaluation with ID=$id');
      return id;
    } catch (e, s) {
      AppLogger.error('EvaluationLocalDataSource.insertEvaluation → DB error', e, s);
      rethrow;
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
      where: '${EvaluationFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return EvaluationEntity.fromMap(maps.first);
    }
    return null;
  }
}
