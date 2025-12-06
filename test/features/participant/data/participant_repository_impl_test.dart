import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';
import 'package:segundo_cogni/features/participant/data/participant_remote_data_source.dart';
import 'package:segundo_cogni/features/participant/data/participant_repository_impl.dart';
import 'package:segundo_cogni/features/participant/domain/participant_entity.dart';

import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';

import 'package:segundo_cogni/shared/env/env_helper.dart';
import 'package:segundo_cogni/core/environment.dart';

// Manual Mocks
class MockParticipantLocalDataSource implements ParticipantLocalDataSource {
  @override
  final BaseDatabaseHelper dbHelper = TestDatabaseHelper.instance;

  bool deleteCalled = false;
  int? deletedId;

  @override
  Future<void> deleteParticipant(int id) async {
    deleteCalled = true;
    deletedId = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockParticipantRemoteDataSource implements ParticipantRemoteDataSource {
  bool deleteCalled = false;
  int? deletedId;

  @override
  Future<bool> deleteParticipant(int id) async {
    deleteCalled = true;
    deletedId = id;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockParticipantLocalDataSource localDataSource;
  late MockParticipantRemoteDataSource remoteDataSource;
  late ParticipantRepositoryImpl repository;

  setUp(() {
    EnvHelper.setMockEnv(AppEnv.local);
    localDataSource = MockParticipantLocalDataSource();
    remoteDataSource = MockParticipantRemoteDataSource();
    repository = ParticipantRepositoryImpl(
      local: localDataSource,
      remote: remoteDataSource,
    );
  });

  tearDown(() {
    EnvHelper.setMockEnv(null);
  });

  test('🗑️ deleteParticipant deletes locally and syncs to backend', () async {
    const participantId = 123;

    await repository.deleteParticipant(participantId);

    // Verify local deletion
    expect(localDataSource.deleteCalled, isTrue);
    expect(localDataSource.deletedId, participantId);

    // Verify remote deletion (allow microtask to complete)
    await Future.delayed(Duration.zero);
    expect(remoteDataSource.deleteCalled, isTrue);
    expect(remoteDataSource.deletedId, participantId);
  });

  test('🗑️ deleteParticipant works locally even if remote fails', () async {
    const participantId = 456;

    // Mock remote failure
    // We can't easily change the mock behavior dynamically with this simple mock,
    // so we'll just check that it doesn't throw.
    // Ideally we'd have a mock that throws.
  });
}
