// test/features/module/module_local_datasource_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_cogni/core/database/test_database_helper.dart';
import 'package:segundo_cogni/features/module/data/module_local_datasource.dart';
import 'package:segundo_cogni/features/module/data/module_model.dart';

void main() {
  late TestDatabaseHelper dbHelper;
  late ModuleLocalDataSource ds;

  setUp(() async {
    dbHelper = TestDatabaseHelper.instance;
    ds = ModuleLocalDataSource();
    await dbHelper.database;
  });

  tearDown(() async {
    await dbHelper.close();
  });

  test('insertModule and getModuleById', () async {
    final module = ModuleModel(
      moduleID: null,
      title: 'Memory',
    );

    final id = await ds.insertModule(module);
    expect(id, isNotNull);

    final fetched = await ds.getModuleById(id!);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Memory');
  });
}
