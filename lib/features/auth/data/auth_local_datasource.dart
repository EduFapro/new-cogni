import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/logger/app_logger.dart';
import '../../evaluator/data/evaluator_model.dart';
import '../../evaluator/data/evaluator_constants.dart';

class AuthLocalDataSource {
  final Database _db;
  AuthLocalDataSource(this._db);

  Future<EvaluatorModel?> getAdminByEmail(String email) async {
    AppLogger.db('Query admin by email: $email');
    final result = await _db.query(
      'evaluators',
      where: '${EvaluatorFields.email} = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) {
      AppLogger.db('No admin found for $email');
      return null;
    }
    AppLogger.db('Admin found for $email');
    return EvaluatorModel.fromMap(result.first);
  }

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    AppLogger.db('Saving current user to DB');
    await _db.delete('current_user');
    await _db.insert('current_user', user.toMap());
  }

  Future<void> clearCurrentUser() async {
    AppLogger.db('Clearing current user from DB');
    await _db.delete('current_user');
  }

  Future<EvaluatorModel?> getCachedUser() async {
    AppLogger.db('Fetching cached user from DB');
    final result = await _db.query('current_user', limit: 1);
    if (result.isEmpty) return null;
    return EvaluatorModel.fromMap(result.first);
  }
}
