import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_local_datasource.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late EvaluatorLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    final db = await dbHelper.database;
    ds = EvaluatorLocalDataSource(db);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insert and getFirstEvaluator', () async {
    final model = EvaluatorModel(
      evaluatorId: null,
      name: 'Test',
      surname: 'Evaluator',
      email: 'test@local',
      birthDate: '1990-01-01',
      specialty: 'Spec',
      cpfOrNif: '000',
      username: 'test',
      password: '123',
      firstLogin: false,
    );

    await ds.insert(model);
    final first = await ds.getFirstEvaluator();

    expect(first, isNotNull);
    expect(first!.email, 'test@local');
  });
}
