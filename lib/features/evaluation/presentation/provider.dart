import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../data/evaluation_local_datasource.dart';
import '../data/evaluation_repository_impl.dart';
import '../domain/evaluation_repository.dart';

// Provide the database helper
final evaluationDbHelperProvider = Provider((ref) {
  return ProdDatabaseHelper.instance;
});

// Provide the data source
final evaluationLocalDataSourceProvider = Provider((ref) {
  final dbHelper = ref.watch(evaluationDbHelperProvider);
  return EvaluationLocalDataSource(dbHelper: dbHelper);
});

// Provide the repository
final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  final local = ref.watch(evaluationLocalDataSourceProvider);
  return EvaluationRepositoryImpl(local: local);
});
