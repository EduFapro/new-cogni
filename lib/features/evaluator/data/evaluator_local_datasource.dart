import 'package:sqflite_common/sqlite_api.dart';

import 'evaluator_model.dart';

class EvaluatorLocalDataSource {
  final Database db;
  EvaluatorLocalDataSource(this.db);

  Future<int> insert(EvaluatorModel evaluator) =>
      db.insert('evaluators', evaluator.toMap());

  Future<bool> hasAnyEvaluatorAdmin() async {
    final result = await db.query(
      'evaluators',
      where: 'is_admin = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty;
  }


  Future<EvaluatorModel?> getFirst() async {
    final maps = await db.query('evaluators', limit: 1);
    if (maps.isNotEmpty) return EvaluatorModel.fromMap(maps.first);
    return null;
  }
}
