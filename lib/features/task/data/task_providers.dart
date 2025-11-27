import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/database_provider.dart';
import '../domain/task_repository.dart';
import 'task_local_datasource.dart';
import 'task_repository_impl.dart';

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final dbHelper = ref.read(databaseProvider);
  return TaskLocalDataSource(dbHelper: dbHelper);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localDataSource = ref.read(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(localDataSource: localDataSource);
});
