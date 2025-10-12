import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/logger/app_logger.dart';
import 'evaluator_model.dart';
import 'evaluator_constants.dart';

class EvaluatorLocalDataSource {
  final Database _db;
  EvaluatorLocalDataSource(this._db);

  Future<List<EvaluatorModel>> getAll() async {
    AppLogger.db('Querying all evaluators from local DB');
    final result = await _db.query(Tables.evaluators);
    AppLogger.db('Fetched ${result.length} evaluators');
    return result.map(EvaluatorModel.fromMap).toList();
  }

  Future<void> insert(EvaluatorModel evaluator) async {
    AppLogger.db('Inserting evaluator: ${evaluator.email}');
    await _db.insert(
      Tables.evaluators,
      evaluator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EvaluatorModel?> getById(int id) async {
    AppLogger.db('Querying evaluator by ID: $id');
    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) {
      AppLogger.db('No evaluator found for ID=$id');
      return null;
    }
    AppLogger.db('Evaluator found for ID=$id');
    return EvaluatorModel.fromMap(result.first);
  }

  Future<int> deleteById(int id) async {
    AppLogger.db('Deleting evaluator ID=$id');
    final count = await _db.delete(
      Tables.evaluators,
      where: '${EvaluatorFields.id} = ?',
      whereArgs: [id],
    );
    AppLogger.db('Deleted $count evaluator(s)');
    return count;
  }

  Future<bool> hasAnyEvaluatorAdmin() async {
    AppLogger.db('Checking if any evaluator admin exists...');
    try {
      final result = await _db.query(
        Tables.evaluators,
        where: '${EvaluatorFields.isAdmin} = ?',
        whereArgs: [1], // since isAdmin is stored as INTEGER (0 or 1)
        limit: 1,
      );
      final exists = result.isNotEmpty;
      AppLogger.db('Admin evaluator exists: $exists');
      return exists;
    } catch (e, s) {
      AppLogger.error('Error checking for evaluator admin', e, s);
      return false;
    }
  }
}
