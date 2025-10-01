import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'database_helper.dart';
import 'core/app_database.dart';
import 'features/evaluator/data/evaluator_local_datasource.dart';
import 'features/evaluator/data/evaluator_remote_datasource.dart';
import 'features/evaluator/data/evaluator_repository_impl.dart';
import 'features/evaluator/domain/evaluator_repository.dart';

enum AppEnv { local, remote }

final environmentProvider = Provider<AppEnv>((_) => AppEnv.local);

final evaluatorRepositoryProvider = FutureProvider<EvaluatorRepository>((ref) async {

  final env = ref.watch(environmentProvider);

  if (env == AppEnv.local) {
    final db = await DatabaseHelper().db;
    return EvaluatorRepositoryImpl.local(EvaluatorLocalDataSource(db));
  } else {
    return EvaluatorRepositoryImpl.remote(EvaluatorRemoteDataSource());
  }
});
