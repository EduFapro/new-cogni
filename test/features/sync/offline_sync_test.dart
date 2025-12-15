import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:segundo_cogni/core/environment.dart';
import 'package:segundo_cogni/shared/env/env_helper.dart';
import 'package:segundo_cogni/features/participant/data/participant_repository_impl.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';
import 'package:segundo_cogni/features/participant/data/participant_remote_data_source.dart';
import 'package:segundo_cogni/features/participant/domain/participant_entity.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_repository_impl.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_local_datasource.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_remote_data_source.dart';
import 'package:segundo_cogni/features/evaluator/domain/evaluator_registration_data.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_repository_impl.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_local_datasource.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_remote_data_source.dart';
import 'package:segundo_cogni/features/evaluation/domain/evaluation_entity.dart';
import 'package:segundo_cogni/core/constants/enums/progress_status.dart';
import 'package:segundo_cogni/core/constants/enums/person_enums.dart';
import 'package:segundo_cogni/core/constants/enums/laterality_enums.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_repository_impl.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_local_datasource.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_remote_data_source.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_repository_impl.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_local_datasource.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_remote_data_source.dart';
import 'package:segundo_cogni/features/module_instance/domain/module_instance_entity.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_model.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_repository_impl.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_local_datasource.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_remote_data_source.dart';
import 'package:segundo_cogni/features/recording_file/domain/recording_file_entity.dart';
import 'package:segundo_cogni/features/task/domain/task_repository.dart';
import 'package:segundo_cogni/core/database/base_database_helper.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'offline_sync_test.mocks.dart';

@GenerateMocks([
  ParticipantLocalDataSource,
  ParticipantRemoteDataSource,
  EvaluatorLocalDataSource,
  EvaluatorRemoteDataSource,
  EvaluationLocalDataSource,
  EvaluationRemoteDataSource,
  TaskInstanceLocalDataSource,
  TaskInstanceRemoteDataSource,
  ModuleInstanceLocalDataSource,
  ModuleInstanceRemoteDataSource,
  RecordingFileLocalDataSource,
  RecordingFileRemoteDataSource,
  Database,
  BaseDatabaseHelper,
  TaskRepository,
])
void main() {
  late MockParticipantLocalDataSource mockParticipantLocal;
  late MockParticipantRemoteDataSource mockParticipantRemote;
  late ParticipantRepositoryImpl participantRepo;

  late MockEvaluatorLocalDataSource mockEvaluatorLocal;
  late MockEvaluatorRemoteDataSource mockEvaluatorRemote;
  late EvaluatorRepositoryImpl evaluatorRepo;

  late MockEvaluationLocalDataSource mockEvaluationLocal;
  late MockEvaluationRemoteDataSource mockEvaluationRemote;
  late EvaluationRepositoryImpl evaluationRepo;

  late MockTaskInstanceLocalDataSource mockTaskInstanceLocal;
  late MockTaskInstanceRemoteDataSource mockTaskInstanceRemote;
  late MockTaskRepository mockTaskRepository;
  late TaskInstanceRepositoryImpl taskInstanceRepo;

  late MockModuleInstanceLocalDataSource mockModuleInstanceLocal;
  late MockModuleInstanceRemoteDataSource mockModuleInstanceRemote;
  late ModuleInstanceRepositoryImpl moduleInstanceRepo;

  late MockRecordingFileLocalDataSource mockRecordingFileLocal;
  late MockRecordingFileRemoteDataSource mockRecordingFileRemote;
  late RecordingFileRepositoryImpl recordingFileRepo;

  late MockDatabase mockDb;
  late MockBaseDatabaseHelper mockDbHelper;

  setUp(() {
    mockParticipantLocal = MockParticipantLocalDataSource();
    mockParticipantRemote = MockParticipantRemoteDataSource();
    mockDbHelper = MockBaseDatabaseHelper();
    mockDb = MockDatabase();
    when(mockParticipantLocal.dbHelper).thenReturn(mockDbHelper);
    when(mockDbHelper.database).thenAnswer((_) async => mockDb);
    participantRepo = ParticipantRepositoryImpl(
      local: mockParticipantLocal,
      remote: mockParticipantRemote,
    );

    mockEvaluatorLocal = MockEvaluatorLocalDataSource();
    mockEvaluatorRemote = MockEvaluatorRemoteDataSource();
    evaluatorRepo = EvaluatorRepositoryImpl(
      local: mockEvaluatorLocal,
      remote: mockEvaluatorRemote,
    );

    mockEvaluationLocal = MockEvaluationLocalDataSource();
    mockEvaluationRemote = MockEvaluationRemoteDataSource();
    when(mockEvaluationLocal.dbHelper).thenReturn(mockDbHelper);
    when(mockEvaluationLocal.getById(any, any)).thenAnswer((_) async => null);
    evaluationRepo = EvaluationRepositoryImpl(
      local: mockEvaluationLocal,
      remote: mockEvaluationRemote,
    );

    mockTaskInstanceLocal = MockTaskInstanceLocalDataSource();
    mockTaskInstanceRemote = MockTaskInstanceRemoteDataSource();
    mockTaskRepository = MockTaskRepository();
    taskInstanceRepo = TaskInstanceRepositoryImpl(
      localDataSource: mockTaskInstanceLocal,
      remoteDataSource: mockTaskInstanceRemote,
      taskRepository: mockTaskRepository,
    );

    mockModuleInstanceLocal = MockModuleInstanceLocalDataSource();
    mockModuleInstanceRemote = MockModuleInstanceRemoteDataSource();
    moduleInstanceRepo = ModuleInstanceRepositoryImpl(
      localDataSource: mockModuleInstanceLocal,
      remoteDataSource: mockModuleInstanceRemote,
    );

    mockRecordingFileLocal = MockRecordingFileLocalDataSource();
    mockRecordingFileRemote = MockRecordingFileRemoteDataSource();
    recordingFileRepo = RecordingFileRepositoryImpl(
      localDataSource: mockRecordingFileLocal,
      remoteDataSource: mockRecordingFileRemote,
    );
  });

  void setEnv(AppEnv mode) {
    EnvHelper.setMockEnv(mode);
  }

  tearDown(() {
    EnvHelper.setMockEnv(null);
  });

  group('ParticipantRepositoryImpl Sync Tests', () {
    final participant = ParticipantEntity(
      participantID: 1,
      name: 'Test',
      surname: 'User',
      birthDate: DateTime(1990, 1, 1),
      sex: Sex.male,
      educationLevel: EducationLevel.completeCollege,
      laterality: Laterality.rightHanded,
    );

    test('deleteParticipant: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(
        mockParticipantLocal.deleteParticipant(any),
      ).thenAnswer((_) async {});

      await participantRepo.deleteParticipant(1);

      verify(mockParticipantLocal.deleteParticipant(1)).called(1);
      verifyZeroInteractions(mockParticipantRemote);
    });

    test('deleteParticipant: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(
        mockParticipantLocal.deleteParticipant(any),
      ).thenAnswer((_) async {});
      when(
        mockParticipantRemote.deleteParticipant(any),
      ).thenAnswer((_) async => true);

      await participantRepo.deleteParticipant(1);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockParticipantRemote.deleteParticipant(1)).called(1);
    });
  });

  group('EvaluatorRepositoryImpl Sync Tests', () {
    final evaluatorData = EvaluatorRegistrationData(
      name: 'Test',
      surname: 'Evaluator',
      email: 'test@test.com',
      birthDate: '1990-01-01',
      specialty: 'Psychology',
      cpf: '12345678900',
      username: 'test',
      password: 'password',
    );

    test('insertEvaluator: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(mockEvaluatorLocal.insert(any)).thenAnswer((_) async => 1);

      await evaluatorRepo.insertEvaluator(evaluatorData);

      verify(mockEvaluatorLocal.insert(any)).called(1);
      verifyZeroInteractions(mockEvaluatorRemote);
    });

    test('insertEvaluator: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(mockEvaluatorLocal.insert(any)).thenAnswer((_) async => 1);
      when(
        mockEvaluatorRemote.createEvaluator(any),
      ).thenAnswer((_) async => 'uuid-1');

      await evaluatorRepo.insertEvaluator(evaluatorData);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockEvaluatorRemote.createEvaluator(any)).called(1);
    });
  });

  group('EvaluationRepositoryImpl Sync Tests', () {
    test('setEvaluationStatus: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(
        mockDb.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await evaluationRepo.setEvaluationStatus(1, EvaluationStatus.completed);

      verify(
        mockDb.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).called(1);
      verifyZeroInteractions(mockEvaluationRemote);
    });

    test('setEvaluationStatus: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(
        mockDb.update(
          any,
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => 1);
      when(
        mockEvaluationRemote.updateEvaluationStatus(any, any),
      ).thenAnswer((_) async => true);

      await evaluationRepo.setEvaluationStatus(1, EvaluationStatus.completed);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockEvaluationRemote.updateEvaluationStatus(1, 3)).called(1);
    });
  });

  group('TaskInstanceRepositoryImpl Sync Tests', () {
    final taskInstance = TaskInstanceEntity(
      id: 1,
      taskId: 1,
      moduleInstanceId: 1,
      status: ProgressStatus.pending,
    );

    test('insert: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(mockTaskInstanceLocal.create(any)).thenAnswer((_) async => 1);

      await taskInstanceRepo.insert(taskInstance);

      verify(mockTaskInstanceLocal.create(any)).called(1);
      verifyZeroInteractions(mockTaskInstanceRemote);
    });

    test('insert: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(mockTaskInstanceLocal.create(any)).thenAnswer((_) async => 1);
      when(
        mockTaskInstanceRemote.createTaskInstance(any),
      ).thenAnswer((_) async => 1);

      await taskInstanceRepo.insert(taskInstance);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockTaskInstanceRemote.createTaskInstance(any)).called(1);
    });
  });

  group('ModuleInstanceRepositoryImpl Sync Tests', () {
    final moduleInstance = ModuleInstanceEntity(
      id: 1,
      moduleId: 1,
      evaluationId: 1,
      status: ProgressStatus.pending,
    );

    test('createModuleInstance: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(
        mockModuleInstanceLocal.insertModuleInstance(any),
      ).thenAnswer((_) async => 1);
      when(
        mockModuleInstanceLocal.getModuleInstanceById(1),
      ).thenAnswer((_) async => ModuleInstanceModel.fromEntity(moduleInstance));

      await moduleInstanceRepo.createModuleInstance(moduleInstance);

      verify(mockModuleInstanceLocal.insertModuleInstance(any)).called(1);
      verifyZeroInteractions(mockModuleInstanceRemote);
    });

    test('createModuleInstance: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(
        mockModuleInstanceLocal.insertModuleInstance(any),
      ).thenAnswer((_) async => 1);
      when(
        mockModuleInstanceLocal.getModuleInstanceById(1),
      ).thenAnswer((_) async => ModuleInstanceModel.fromEntity(moduleInstance));
      when(
        mockModuleInstanceRemote.createModuleInstance(any),
      ).thenAnswer((_) async => 1);

      await moduleInstanceRepo.createModuleInstance(moduleInstance);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockModuleInstanceRemote.createModuleInstance(any)).called(1);
    });
  });

  group('RecordingFileRepositoryImpl Sync Tests', () {
    final recording = RecordingFileEntity(
      id: 1,
      taskInstanceId: 1,
      filePath: '/tmp/test.m4a',
    );

    test('insert: does NOT sync in offline mode', () async {
      setEnv(AppEnv.offline);
      when(mockRecordingFileLocal.insert(any)).thenAnswer((_) async => 1);

      await recordingFileRepo.insert(recording);

      verify(mockRecordingFileLocal.insert(any)).called(1);
      verifyZeroInteractions(mockRecordingFileRemote);
    });

    test('insert: syncs in local mode', () async {
      setEnv(AppEnv.local);
      when(mockRecordingFileLocal.insert(any)).thenAnswer((_) async => 1);
      when(
        mockRecordingFileRemote.createRecordingFile(any),
      ).thenAnswer((_) async => 1);

      await recordingFileRepo.insert(recording);
      await Future.delayed(Duration(milliseconds: 50));

      verify(mockRecordingFileRemote.createRecordingFile(any)).called(1);
    });
  });
}
