import 'package:sqflite_common/sqlite_api.dart';
import '../../evaluator/data/evaluator_model.dart';
import '../../evaluator/data/evaluator_constants.dart';

class AuthLocalDataSource {
  final Database _db;

  AuthLocalDataSource(this._db);

  Future<EvaluatorModel?> getAdminByEmail(String email) async {
    final result = await _db.query(
      'evaluators',
      where: '${EvaluatorFields.email} = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return EvaluatorModel.fromMap(result.first);
  }

  // --- Added for caching support ---

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    // Replace any previous cached record
    await _db.delete('current_user');
    await _db.insert('current_user', user.toMap());
  }

  Future<void> clearCurrentUser() async {
    await _db.delete('current_user');
  }

  Future<EvaluatorModel?> getCachedUser() async {
    final result = await _db.query('current_user', limit: 1);
    if (result.isEmpty) return null;
    return EvaluatorModel.fromMap(result.first);
  }
}
