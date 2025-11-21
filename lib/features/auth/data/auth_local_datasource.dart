import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../../shared/encryption/deterministic_encryption_helper.dart';
import '../../evaluator/application/evaluator_secure_service.dart';
import '../../evaluator/data/evaluator_model.dart';
import '../../evaluator/data/evaluator_constants.dart';

class AuthLocalDataSource {
  final Database _db;
  AuthLocalDataSource(this._db);
  Future<EvaluatorModel?> getEvaluatorByEmail(String email) async {
    final encryptedEmail = DeterministicEncryptionHelper.encryptText(email);
    AppLogger.debug('Looking up evaluator: $email (encrypted: $encryptedEmail)');

    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.email} = ?',
      whereArgs: [encryptedEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      AppLogger.db('No evaluator found for $email');
      return null;
    }

    AppLogger.db('Evaluator found for $email');
    return EvaluatorModel.fromMap(result.first);
  }


  Future<void> clearCurrentUser() async {
    AppLogger.db('Clearing current user from DB');
    await _db.delete('current_user');
  }

  Future<EvaluatorModel?> getCachedUser() async {
    AppLogger.db('Fetching cached user from DB');
    final result = await _db.query('current_user', limit: 1);
    if (result.isEmpty) return null;

    final encrypted = EvaluatorModel.fromMap(result.first);
    return EvaluatorSecureService.decrypt(encrypted);
  }

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    AppLogger.db('Encrypting and saving current user to DB');
    final encrypted = EvaluatorSecureService.encrypt(user);
    await _db.delete('current_user');
    await _db.insert('current_user', encrypted.toMap());
  }
}
