import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/prod_database_helper.dart';
import '../../data/evaluator_local_datasource.dart';
import '../../data/evaluator_model.dart';

final currentEvaluatorProvider = FutureProvider<EvaluatorModel?>((ref) async {
  final db = await ProdDatabaseHelper.instance.database;
  final ds = EvaluatorLocalDataSource(db);
  return await ds.getFirstEvaluator();
});
