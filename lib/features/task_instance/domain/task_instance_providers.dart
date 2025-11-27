import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../providers/database_provider.dart';
import '../../task/data/task_providers.dart';
import '../data/task_instance_local_datasource.dart';
import '../data/task_instance_repository_impl.dart';
import 'task_instance_entity.dart';
import 'task_instance_repository.dart';

final taskInstanceLocalDataSourceProvider =
    Provider<TaskInstanceLocalDataSource>((ref) {
      final dbHelper = ref.read(databaseProvider);
      return TaskInstanceLocalDataSource(dbHelper: dbHelper);
    });

final taskInstanceRepositoryProvider = Provider<TaskInstanceRepository>((ref) {
  final localDataSource = ref.read(taskInstanceLocalDataSourceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  return TaskInstanceRepositoryImpl(
    localDataSource: localDataSource,
    taskRepository: taskRepository,
  );
});

final taskInstanceByIdProvider =
    FutureProvider.family<TaskInstanceEntity?, int>((ref, id) {
      final repo = ref.read(taskInstanceRepositoryProvider);
      return repo.getInstanceWithTask(id);
    });
