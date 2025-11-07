import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_local_datasource.dart';
import 'package:segundo_cogni/features/task_prompt/data/task_prompt_model.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late TaskPromptLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    ds = TaskPromptLocalDataSource();
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insert and getByTaskId', () async {
    final model = TaskPromptModel(
      promptID: null,
      taskID: 1,
      transcription: 'Say your name', filePath: '',
      // other fields if required
    );

    final id = await ds.insert(model);
    expect(id, isNotNull);

    final fetched = await ds.getByTaskId(1);
    expect(fetched, isNotNull);
    expect(fetched!.transcription, 'Say your name');
  });
}
