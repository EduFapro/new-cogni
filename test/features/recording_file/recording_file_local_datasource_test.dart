// test/features/recording_file/recording_file_local_datasource_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_local_datasource.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_model.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late RecordingFileLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    ds = RecordingFileLocalDataSource();
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insert and getById', () async {
    final model = RecordingFileModel(
      id: null,
      taskInstanceId: 1,
       filePath: '',
      // other fields if required
    );

    final id = await ds.insert(model);
    expect(id, isNotNull);

    final fetched = await ds.getById(id!);
    expect(fetched, isNotNull);
  });
}
