
import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/utils/encryption_helper.dart';
import '../application/evaluator_secure_service.dart';
import 'evaluator_model.dart';
import 'evaluator_constants.dart';

class EvaluatorLocalDataSource {
  final Database _db;
  EvaluatorLocalDataSource(this._db);

  /// Fetch all evaluators
  Future<List<EvaluatorModel>> getAll() async {
    AppLogger.db('[EVALUATOR] Fetching all evaluators');
    final result = await _db.query(Tables.evaluators);
    return result.map(EvaluatorModel.fromMap).toList();
  }

  /// Insert evaluator (replace on conflict)
  Future<void> insert(EvaluatorModel evaluator) async {
    AppLogger.db('[EVALUATOR] Inserting evaluator: ${evaluator.email}');
    await _db.insert(
      Tables.evaluators,
      evaluator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get evaluator by ID
  Future<EvaluatorModel?> getById(int id) async {
    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? EvaluatorModel.fromMap(result.first) : null;
  }

  Future<EvaluatorModel?> getFirstEvaluator() async {
    final result = await _db.query(
      Tables.evaluators,
      orderBy: '${EvaluatorFields.id} ASC',
      limit: 1,
    );
    return result.isNotEmpty ? EvaluatorModel.fromMap(result.first) : null;
  }


  /// ✅ NEW: Check if there is any evaluator admin (legacy support)
  Future<bool> hasAnyEvaluatorAdmin() async {
    AppLogger.db('[EVALUATOR] Checking if any admin evaluator exists...');
    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.isAdmin} = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Delete evaluator
  Future<int> deleteById(int id) async {
    return await _db.delete(
      Tables.evaluators,
      where: '${EvaluatorFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> existsByEmail(String email) async {
    AppLogger.db('[EVALUATOR] Checking if evaluator exists for email: $email');
    try {
      final result = await _db.query(
        Tables.evaluators,
        where: '${EvaluatorFields.email} = ?',
        whereArgs: [email],
        limit: 1,
      );
      final exists = result.isNotEmpty;
      AppLogger.db('[EVALUATOR] existsByEmail($email) → $exists');
      return exists;
    } catch (e, s) {
      AppLogger.error('[EVALUATOR] Error checking existsByEmail', e, s);
      return false;
    }
  }



  Future<EvaluatorModel?> login(String username, String password) async {
    final encryptedUsername = EncryptionHelper.encryptText(username);
    final hashedPassword = EvaluatorSecureService.hash(password);

    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.username} = ? AND ${EvaluatorFields.password} = ?',
      whereArgs: [encryptedUsername, hashedPassword],
      limit: 1,
    );

    return result.isNotEmpty ? EvaluatorModel.fromMap(result.first) : null;
  }

}
