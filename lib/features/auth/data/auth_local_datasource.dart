import 'package:segundo_cogni/features/evaluator/data/evaluator_model_extensions.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/logger/app_logger.dart';
import '../../evaluator/application/evaluator_secure_service.dart';
import '../../evaluator/data/evaluator_model.dart';
import '../../evaluator/data/evaluator_constants.dart';

class AuthLocalDataSource {
  final Database _db;
  AuthLocalDataSource(this._db);

  Future<EvaluatorModel?> getEvaluatorByEmail(String email) async {
    AppLogger.db('Query evaluator by email: $email');
    final result = await _db.query(
      Tables.evaluators,
      where: '${EvaluatorFields.email} = ?',
      whereArgs: [email],
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
    return EvaluatorSecureService.decryptEvaluator(EvaluatorModel.fromMap(result.first));
  }

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    AppLogger.db('Encrypting and saving current user to DB');
    final encrypted = EvaluatorSecureService.processEvaluatorForStorage(user);
    await _db.delete('current_user');
    await _db.insert('current_user', encrypted.toMap());
  }

}
