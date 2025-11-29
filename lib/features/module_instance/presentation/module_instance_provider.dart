import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/prod_database_helper.dart';
import '../../../providers/network_provider.dart';
import '../data/module_instance_local_datasource.dart';
import '../data/module_instance_remote_data_source.dart';
import '../data/module_instance_repository_impl.dart';
import '../domain/module_instance_entity.dart';
import '../domain/module_instance_repository.dart';

final moduleInstanceDbHelperProvider = Provider((ref) {
  return ProdDatabaseHelper.instance;
});

final moduleInstanceRepositoryProvider = Provider<ModuleInstanceRepository>((
  ref,
) {
  final dbHelper = ref.watch(moduleInstanceDbHelperProvider);
  final local = ModuleInstanceLocalDataSource(dbHelper: dbHelper);

  final networkService = ref.watch(networkServiceProvider);
  final remote = ModuleInstanceRemoteDataSource(networkService);

  return ModuleInstanceRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

/// Provider for fetching module instances by evaluation ID
/// This allows the UI to reactively update when modules are completed
final moduleInstancesByEvaluationProvider =
    FutureProvider.family<List<ModuleInstanceEntity>, int>((
      ref,
      evaluationId,
    ) async {
      final repo = ref.watch(moduleInstanceRepositoryProvider);
      return repo.getModuleInstancesByEvaluationId(evaluationId);
    });
