import 'package:sqflite_common/sqlite_api.dart';

import '../../../core/constants/database_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../../shared/encryption/deterministic_encryption_helper.dart';
import '../application/evaluator_secure_service.dart';
import 'evaluator_constants.dart';
import 'evaluator_model.dart';

class EvaluatorLocalDataSource {
  final DatabaseExecutor _db;
  EvaluatorLocalDataSource(this._db);

  /// Insert evaluator securely (encrypt PII, hash password)
  Future<void> insert(EvaluatorModel evaluator) async {
    AppLogger.db('[EVALUATOR] Inserting evaluator: ${evaluator.email}');
    final secured = EvaluatorSecureService.encrypt(evaluator);
    await _db.insert(
      Tables.evaluators,
      secured.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all evaluators (decrypted)
  Future<List<EvaluatorModel>> getAll() async {
    AppLogger.db('[EVALUATOR] Fetching all evaluators');
    final result = await _db.query(Tables.evaluators);
    return result
        .map(EvaluatorModel.fromMap)
        .map(EvaluatorSecureService.decrypt)
        .toList();
  }

  /// Get evaluator by ID (decrypted)
  Future<EvaluatorModel?> getById(int id) async {
    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty
        ? EvaluatorSecureService.decrypt(EvaluatorModel.fromMap(result.first))
        : null;
  }

  /// Get the first evaluator (decrypted)
  Future<EvaluatorModel?> getFirstEvaluator() async {
    final result = await _db.query(
      Tables.evaluators,
      orderBy: '${EvaluatorFields.id} ASC',
      limit: 1,
    );
    return result.isNotEmpty
        ? EvaluatorSecureService.decrypt(EvaluatorModel.fromMap(result.first))
        : null;
  }

  /// Legacy support: check if any admin exists
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

  /// Existence check by email (encrypt the lookup value)
  Future<bool> existsByEmail(String email) async {
    AppLogger.db('[EVALUATOR] Checking if evaluator exists for email: $email');
    try {
      final encEmail = DeterministicEncryptionHelper.encryptText(email);
      final result = await _db.query(
        Tables.evaluators,
        where: '${EvaluatorFields.email} = ?',
        whereArgs: [encEmail],
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

  /// Login using encrypted username + hashed password
  Future<EvaluatorModel?> login(String username, String password) async {
    final encryptedUsername = DeterministicEncryptionHelper.encryptText(username);
    final hashedPassword = EvaluatorSecureService.hash(password);

    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.username} = ? AND ${EvaluatorFields.password} = ?',
      whereArgs: [encryptedUsername, hashedPassword],
      limit: 1,
    );

    return result.isNotEmpty
        ? EvaluatorSecureService.decrypt(EvaluatorModel.fromMap(result.first))
        : null;
  }
}
