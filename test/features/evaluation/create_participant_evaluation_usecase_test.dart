import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_local_datasource.dart';
import 'package:segundo_cogni/features/evaluation/domain/usecases/create_participant_evaluation_usecase.dart';
import 'package:segundo_cogni/features/participant/data/participant_local_datasource.dart';
import 'package:segundo_cogni/features/participant/domain/participant_entity.dart';
import 'package:segundo_cogni/features/task/data/task_local_datasource.dart';
import 'package:segundo_cogni/features/module/domain/module_repository.dart';
import 'package:segundo_cogni/features/module_instance/domain/module_instance_repository.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_repository.dart';
import 'package:segundo_cogni/features/module/domain/module_entity.dart';
import 'package:segundo_cogni/features/module_instance/domain/module_instance_entity.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';
import 'package:segundo_cogni/core/constants/enums/person_enums.dart';
import 'package:segundo_cogni/core/constants/enums/laterality_enums.dart';
import 'package:segundo_cogni/core/constants/enums/progress_status.dart';

// Mocks
class MockModuleRepository implements ModuleRepository {
  @override
  Future<List<ModuleEntity>> getAllModules() async {
    return [
      ModuleEntity(moduleID: 1, title: 'Module 1'),
      ModuleEntity(moduleID: 2, title: 'Module 2'),
    ];
  }

  @override
  Future<int?> insertModule(ModuleEntity module) async => 1;

  @override
  Future<ModuleEntity?> getModuleById(int id) async => null;

  @override
  Future<ModuleEntity?> getModuleByTitle(String title) async => null;

  @override
  Future<int> updateModule(ModuleEntity module) async => 1;

  @override
  Future<int> deleteModule(int id) async => 1;

  @override
  Future<int> getNumberOfModules() async => 2;
}

class MockModuleInstanceRepository implements ModuleInstanceRepository {
  @override
  Future<ModuleInstanceEntity?> createModuleInstance(
    ModuleInstanceEntity instance,
  ) async {
    return instance.copyWith(id: 100 + instance.moduleId);
  }

  @override
  Future<int> setModuleInstanceStatus(
    int instanceId,
    ModuleStatus status,
  ) async => 1;

  @override
  Future<int> deleteModuleInstance(int id) async => 1;

  @override
  Future<List<ModuleInstanceEntity>> getAllModuleInstances() async => [];

  @override
  Future<int> getCount() async => 0;

  @override
  Future<ModuleInstanceEntity?> getModuleInstanceById(int id) async => null;

  @override
  Future<List<ModuleInstanceEntity>> getModuleInstancesByEvaluationId(
    int evaluationId,
  ) async => [];

  @override
  Future<int> updateModuleInstance(ModuleInstanceEntity instance) async => 1;
}

class MockTaskInstanceRepository implements TaskInstanceRepository {
  @override
  Future<int?> insert(TaskInstanceEntity instance) async {
    return 200 + instance.taskId;
  }

  @override
  Future<List<TaskInstanceEntity>> getByModuleInstance(
    int moduleInstanceId,
  ) async => [];

  @override
  Future<int> update(TaskInstanceEntity entity) async => 1;

  @override
  Future<int> delete(int id) async => 1;

  @override
  Future<List<TaskInstanceEntity>> getAll() async => [];

  @override
  Future<TaskInstanceEntity?> getById(int id) async => null;

  @override
  Future<TaskInstanceEntity?> getInstanceWithTask(int id) async => null;

  @override
  Future<int> markAsCompleted(int id, {String? duration}) async => 1;
}

void main() {
  late TestDatabaseHelper dbHelper;
  late CreateParticipantEvaluationUseCase useCase;
  late ParticipantLocalDataSource participantDataSource;
  late EvaluationLocalDataSource evaluationDataSource;
  late TaskLocalDataSource taskDataSource;

  setUp(() async {
    await TestDatabaseHelper.delete();
    dbHelper = TestDatabaseHelper.instance;
    final db = await dbHelper.database;

    participantDataSource = ParticipantLocalDataSource(dbHelper: dbHelper);
    evaluationDataSource = EvaluationLocalDataSource(dbHelper: dbHelper);
    taskDataSource = TaskLocalDataSource(dbHelper: dbHelper);

    // Seed a task for Module 1
    await db.insert('tasks', {
      'task_id': 1,
      'module_id': 1,
      'title': 'Task 1',
      'description': 'Task Desc',
      'command': 'Do this',
      'response_type': 'text',
      'media_type': 'none',
      'task_order': 1,
    });

    useCase = CreateParticipantEvaluationUseCase(
      participantDataSource: participantDataSource,
      evaluationDataSource: evaluationDataSource,
      moduleRepository: MockModuleRepository(),
      moduleInstanceRepository: MockModuleInstanceRepository(),
      taskDataSource: taskDataSource,
      taskInstanceRepository: MockTaskInstanceRepository(),
      db: db,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('✅ execute creates participant, evaluation, and instances', () async {
    final participant = ParticipantEntity(
      name: 'Test',
      surname: 'User',
      birthDate: DateTime(2000, 1, 1),
      sex: Sex.male,
      educationLevel: EducationLevel.completeHighSchool,
      laterality: Laterality.rightHanded,
    );

    final created = await useCase.execute(
      participant: participant,
      evaluatorId: 1,
      selectedModuleIds: [1],
    );

    expect(created.participantID, isNotNull);

    // Verify Participant in DB
    final db = await dbHelper.database;
    final savedParticipant = await db.query(
      'participants',
      where: 'participant_id = ?',
      whereArgs: [created.participantID],
    );
    expect(savedParticipant, isNotEmpty);
    expect(savedParticipant.first['name'], isNot('Test')); // Should be hashed

    // Verify Evaluation in DB
    final savedEvaluation = await db.query(
      'evaluations',
      where: 'participant_id = ?',
      whereArgs: [created.participantID],
    );
    expect(savedEvaluation, isNotEmpty);
    expect(savedEvaluation.first['evaluator_id'], 1);

    // Verify Module/Task Instances (Mocked repos don't save to DB, but we verify the flow completed without error)
    // In a real integration test with full DB repos, we would query those tables too.
  });
}
