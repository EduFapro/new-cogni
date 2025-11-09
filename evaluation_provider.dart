import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:segundo_cogni/core/database/prod_database_helper.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_local_datasource.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_repository_impl.dart';
import 'package:segundo_cogni/features/evaluation/domain/evaluation_repository.dart';


final evaluationDbHelperProvider = Provider<ProdDatabaseHelper>((ref) {
  return ProdDatabaseHelper.instance;
});

final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  final dbHelper = ref.watch(evaluationDbHelperProvider);
  return EvaluationRepositoryImpl(
    local: EvaluationLocalDataSource(dbHelper: dbHelper),
  );
});
