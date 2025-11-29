import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/enums/progress_status.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_local_datasource.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_model.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_remote_data_source.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_repository_impl.dart';
import 'package:segundo_cogni/features/module_instance/domain/module_instance_entity.dart';

// Manual Mocks
class MockModuleInstanceLocalDataSource
    implements ModuleInstanceLocalDataSource {
  @override
  final BaseDatabaseHelper dbHelper = TestDatabaseHelper.instance;

  bool insertCalled = false;
  bool setStatusCalled = false;
  ModuleInstanceModel? insertedModel;
  int? statusUpdatedId;
  ModuleStatus? updatedStatus;

  @override
  Future<int?> insertModuleInstance(ModuleInstanceModel instance) async {
    insertCalled = true;
    insertedModel = instance;
    return 100; // Return a dummy ID
  }

  @override
  Future<ModuleInstanceModel?> getModuleInstanceById(int id) async {
    if (id == 100 && insertedModel != null) {
      return insertedModel!.copyWith(id: 100);
    }
    return null;
  }

  @override
  Future<int> setStatus(int instanceId, ModuleStatus status) async {
    setStatusCalled = true;
    statusUpdatedId = instanceId;
    updatedStatus = status;
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockModuleInstanceRemoteDataSource
    implements ModuleInstanceRemoteDataSource {
  bool createCalled = false;
  bool updateStatusCalled = false;
  ModuleInstanceEntity? createdEntity;
  int? statusUpdatedId;
  int? updatedStatusValue;

  @override
  Future<int?> createModuleInstance(ModuleInstanceEntity instance) async {
    createCalled = true;
    createdEntity = instance;
    return 999; // Backend ID
  }

  @override
  Future<bool> updateModuleInstanceStatus(int id, int status) async {
    updateStatusCalled = true;
    statusUpdatedId = id;
    updatedStatusValue = status;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockModuleInstanceLocalDataSource localDataSource;
  late MockModuleInstanceRemoteDataSource remoteDataSource;
  late ModuleInstanceRepositoryImpl repository;

  setUp(() {
    localDataSource = MockModuleInstanceLocalDataSource();
    remoteDataSource = MockModuleInstanceRemoteDataSource();
    repository = ModuleInstanceRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  test('✅ createModuleInstance inserts locally and syncs to backend', () async {
    final instance = ModuleInstanceEntity(
      moduleId: 1,
      evaluationId: 1,
      status: ModuleStatus.pending,
    );

    final result = await repository.createModuleInstance(instance);

    expect(result, isNotNull);
    expect(result!.id, 100);

    // Verify local insert
    expect(localDataSource.insertCalled, isTrue);
    expect(localDataSource.insertedModel?.moduleId, 1);

    // Verify remote sync
    await Future.delayed(Duration.zero);
    expect(remoteDataSource.createCalled, isTrue);
    expect(
      remoteDataSource.createdEntity?.id,
      100,
    ); // Should send entity with local ID
  });

  test(
    '✅ setModuleInstanceStatus updates locally and syncs to backend',
    () async {
      const instanceId = 100;
      const newStatus = ModuleStatus.completed;

      await repository.setModuleInstanceStatus(instanceId, newStatus);

      // Verify local update
      expect(localDataSource.setStatusCalled, isTrue);
      expect(localDataSource.statusUpdatedId, instanceId);
      expect(localDataSource.updatedStatus, newStatus);

      // Verify remote sync
      await Future.delayed(Duration.zero);
      expect(remoteDataSource.updateStatusCalled, isTrue);
      expect(remoteDataSource.statusUpdatedId, instanceId);
      expect(remoteDataSource.updatedStatusValue, newStatus.numericValue);
    },
  );
}
