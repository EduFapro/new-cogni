import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../../../core/logger/app_logger.dart';
import '../data/evaluation_local_datasource.dart';
import '../data/evaluation_repository_impl.dart';
import '../domain/evaluation_repository.dart';

final evaluationDbHelperProvider = Provider((ref) {
  AppLogger.db('Providing ProdDatabaseHelper.instance for evaluation (presentation)');
  return ProdDatabaseHelper.instance;
});

final evaluationLocalDataSourceProvider = Provider((ref) {
  final dbHelper = ref.watch(evaluationDbHelperProvider);
  AppLogger.db('Creating EvaluationLocalDataSource');
  return EvaluationLocalDataSource(dbHelper: dbHelper);
});

final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  final local = ref.watch(evaluationLocalDataSourceProvider);
  AppLogger.info('Creating EvaluationRepositoryImpl (presentation/provider)');
  return EvaluationRepositoryImpl(local: local);
});
