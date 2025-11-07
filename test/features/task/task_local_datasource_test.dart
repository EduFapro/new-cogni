// test/features/task/task_local_datasource_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/constants/enums/task_mode.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/task/data/task_local_datasource.dart';
import 'package:segundo_cogni/features/task/data/task_model.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late TaskLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    ds = TaskLocalDataSource();
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insertTask and getTaskById', () async {
    final task = TaskModel(
      taskID: null,
      moduleID: 1,
      title: 'Task A',
      transcript: 'Desc',
      position: 1,
      taskMode: TaskMode.play,
    );

    final id = await ds.insertTask(task);
    expect(id, isNotNull);

    final fetched = await ds.getTaskById(id!);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Task A');
  });
}
