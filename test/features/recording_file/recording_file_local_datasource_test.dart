import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_local_datasource.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_model.dart';

void main() {
  // ✅ Initialize FFI before tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late TestDatabaseHelper dbHelper;
  late RecordingFileLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    await dbHelper.deleteDb();
    await dbHelper.initDb();
    ds = RecordingFileLocalDataSource(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insert and getById', () async {
    final model = RecordingFileModel(
      id: null,
      taskInstanceId: 1,
      filePath: 'test_audio.wav',
    );

    final id = await ds.insert(model);
    expect(id, isNotNull);

    final fetched = await ds.getById(id!);
    expect(fetched, isNotNull);
    expect(fetched!.filePath, equals(model.filePath));
    expect(fetched.taskInstanceId, equals(model.taskInstanceId));
  });
}
