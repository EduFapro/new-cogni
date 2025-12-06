import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/enums/progress_status.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_local_datasource.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_remote_data_source.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_repository_impl.dart';
import 'package:segundo_cogni/features/evaluation/domain/evaluation_entity.dart';
import 'package:segundo_cogni/shared/env/env_helper.dart';
import 'package:segundo_cogni/core/environment.dart';

// Manual Mocks
class MockEvaluationLocalDataSource implements EvaluationLocalDataSource {
  @override
  final BaseDatabaseHelper dbHelper = TestDatabaseHelper.instance;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockEvaluationRemoteDataSource implements EvaluationRemoteDataSource {
  bool updateStatusCalled = false;
  int? statusUpdatedId;
  int? updatedStatusValue;

  @override
  Future<bool> updateEvaluationStatus(int id, int status) async {
    updateStatusCalled = true;
    statusUpdatedId = id;
    updatedStatusValue = status;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockEvaluationLocalDataSource localDataSource;
  late MockEvaluationRemoteDataSource remoteDataSource;
  late EvaluationRepositoryImpl repository;
  late TestDatabaseHelper dbHelper;

  setUp(() async {
    EnvHelper.setMockEnv(AppEnv.local);
    await TestDatabaseHelper.delete();
    dbHelper = TestDatabaseHelper.instance;
    localDataSource = MockEvaluationLocalDataSource();
    remoteDataSource = MockEvaluationRemoteDataSource();
    repository = EvaluationRepositoryImpl(
      local: localDataSource,
      remote: remoteDataSource,
    );

    // Seed an evaluation
    final db = await dbHelper.database;
    await db.insert('evaluations', {
      'evaluation_id': 123,
      'evaluator_id': 1,
      'participant_id': 1,
      'status': 0, // pending
      'evaluation_date': DateTime.now().toIso8601String(),
      'language': 1,
    });
  });

  tearDown(() async {
    await dbHelper.close();
    EnvHelper.setMockEnv(null);
  });

  test('✅ setEvaluationStatus updates locally and syncs to backend', () async {
    const evaluationId = 123;
    const newStatus = EvaluationStatus.completed;

    await repository.setEvaluationStatus(evaluationId, newStatus);

    // Verify local update in DB
    final db = await dbHelper.database;
    final result = await db.query(
      'evaluations',
      where: 'evaluation_id = ?',
      whereArgs: [evaluationId],
    );
    expect(result.first['status'], newStatus.numericValue);

    // Verify remote sync
    await Future.delayed(Duration.zero);
    expect(remoteDataSource.updateStatusCalled, isTrue);
    expect(remoteDataSource.statusUpdatedId, evaluationId);
    expect(remoteDataSource.updatedStatusValue, newStatus.numericValue);
  });
}
