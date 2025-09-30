import 'package:sqflite_common/sqlite_api.dart';
import '../../evaluator/data/evaluator_model.dart';

class AuthLocalDataSource {
  final Database db;

  AuthLocalDataSource(this.db);

  Future<EvaluatorModel?> getAdminByEmail(String email) async {
    final result = await db.query(
      'evaluators',
      where: 'email = ? AND is_admin = ?',
      whereArgs: [email, 1],
      limit: 1,
    );


    if (result.isNotEmpty) {
      return EvaluatorModel.fromMap(result.first);
    }

    return null;
  }

}
