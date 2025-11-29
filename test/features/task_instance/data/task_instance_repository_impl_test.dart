import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/enums/progress_status.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/task/domain/task_repository.dart';
import 'package:segundo_cogni/features/task/domain/task_entity.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_local_datasource.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_model.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_remote_data_source.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_repository_impl.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';

// Manual Mocks
class MockTaskInstanceLocalDataSource implements TaskInstanceLocalDataSource {
  @override
  final BaseDatabaseHelper dbHelper = TestDatabaseHelper.instance;

  bool insertCalled = false;
  bool markAsCompletedCalled = false;
  TaskInstanceModel? insertedModel;
  int? completedId;
  String? completedDuration;

  @override
  Future<int?> create(TaskInstanceModel instance) async {
    insertCalled = true;
    insertedModel = instance;
    return 200; // Dummy ID
  }

  @override
  Future<TaskInstanceModel?> getTaskInstance(int id) async {
    if (id == 200 && insertedModel != null) {
      final entity = insertedModel!.copyWith(id: 200);
      return TaskInstanceModel.fromEntity(entity);
    }
    return null;
  }

  @override
  Future<void> markAsCompleted(int id, {String? duration}) async {
    markAsCompletedCalled = true;
    completedId = id;
    completedDuration = duration;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTaskInstanceRemoteDataSource implements TaskInstanceRemoteDataSource {
  bool createCalled = false;
  bool completeCalled = false;
  TaskInstanceEntity? createdEntity;
  int? completedId;
  String? completedDuration;

  @override
  Future<int?> createTaskInstance(TaskInstanceEntity instance) async {
    createCalled = true;
    createdEntity = instance;
    return 888; // Backend ID
  }

  @override
  Future<bool> markAsCompleted(int id, String? duration) async {
    completeCalled = true;
    completedId = id;
    completedDuration = duration;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTaskRepository implements TaskRepository {
  @override
  Future<TaskEntity?> getTaskById(int id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockTaskInstanceLocalDataSource localDataSource;
  late MockTaskInstanceRemoteDataSource remoteDataSource;
  late MockTaskRepository taskRepository;
  late TaskInstanceRepositoryImpl repository;

  setUp(() {
    localDataSource = MockTaskInstanceLocalDataSource();
    remoteDataSource = MockTaskInstanceRemoteDataSource();
    taskRepository = MockTaskRepository();
    repository = TaskInstanceRepositoryImpl(
      localDataSource: localDataSource,
      taskRepository: taskRepository,
      remoteDataSource: remoteDataSource,
    );
  });

  test('✅ insert task instance inserts locally and syncs to backend', () async {
    final instance = TaskInstanceEntity(
      taskId: 1,
      moduleInstanceId: 1,
      status: TaskStatus.pending,
    );

    final result = await repository.insert(instance);

    expect(result, 200);

    // Verify local insert
    expect(localDataSource.insertCalled, isTrue);
    expect(localDataSource.insertedModel?.taskId, 1);

    // Verify remote sync
    await Future.delayed(Duration.zero);
    expect(remoteDataSource.createCalled, isTrue);
    expect(remoteDataSource.createdEntity?.id, 200);
  });

  test('✅ markAsCompleted updates locally and syncs to backend', () async {
    const instanceId = 200;
    const duration = '10:00';

    await repository.markAsCompleted(instanceId, duration: duration);

    // Verify local update
    expect(localDataSource.markAsCompletedCalled, isTrue);
    expect(localDataSource.completedId, instanceId);
    expect(localDataSource.completedDuration, duration);

    // Verify remote sync
    await Future.delayed(Duration.zero);
    expect(remoteDataSource.completeCalled, isTrue);
    expect(remoteDataSource.completedId, instanceId);
    expect(remoteDataSource.completedDuration, duration);
  });
}
