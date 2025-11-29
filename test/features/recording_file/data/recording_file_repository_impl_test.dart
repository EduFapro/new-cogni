import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_local_datasource.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_remote_data_source.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_repository_impl.dart';
import 'package:segundo_cogni/features/recording_file/domain/recording_file_entity.dart';

// Manual Mocks
class MockRecordingFileLocalDataSource implements RecordingFileLocalDataSource {
  @override
  final BaseDatabaseHelper dbHelper = TestDatabaseHelper.instance;

  bool insertCalled = false;
  RecordingFileEntity? insertedEntity;

  @override
  Future<int?> insert(RecordingFileEntity file) async {
    insertCalled = true;
    insertedEntity = file;
    return 300; // Dummy ID
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRecordingFileRemoteDataSource
    implements RecordingFileRemoteDataSource {
  bool createCalled = false;
  RecordingFileEntity? createdEntity;

  @override
  Future<int?> createRecordingFile(RecordingFileEntity file) async {
    createCalled = true;
    createdEntity = file;
    return 777; // Backend ID
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockRecordingFileLocalDataSource localDataSource;
  late MockRecordingFileRemoteDataSource remoteDataSource;
  late RecordingFileRepositoryImpl repository;

  setUp(() {
    localDataSource = MockRecordingFileLocalDataSource();
    remoteDataSource = MockRecordingFileRemoteDataSource();
    repository = RecordingFileRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  test(
    '✅ insert recording file inserts locally and syncs to backend',
    () async {
      final file = RecordingFileEntity(
        taskInstanceId: 1,
        filePath: '/path/to/file',
      );

      final result = await repository.insert(file);

      expect(result, 300);

      // Verify local insert
      expect(localDataSource.insertCalled, isTrue);
      expect(localDataSource.insertedEntity?.filePath, '/path/to/file');

      // Verify remote sync
      await Future.delayed(Duration.zero);
      expect(remoteDataSource.createCalled, isTrue);
      expect(
        remoteDataSource.createdEntity?.id,
        300,
      ); // Should send entity with local ID
    },
  );
}
