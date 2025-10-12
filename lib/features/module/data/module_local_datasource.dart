import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../database_helper.dart';
import 'module_constants.dart';
import 'module_model.dart';

class ModuleLocalDataSource {
  final dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModule(ModuleModel module) async {
    final db = await _db;
    return await db.insert(
      Tables.modules,
      module.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ModuleModel>> getAllModules() async {
    final db = await _db;
    final maps = await db.query(Tables.modules);
    return maps.map((e) => ModuleModel.fromMap(e)).toList();
  }

  Future<ModuleModel?> getModuleById(int id) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
  }

  Future<ModuleModel?> getModuleByTitle(String title) async {
    final db = await _db;
    final result = await db.query(
      Tables.modules,
      where: '${ModuleFields.title} = ?',
      whereArgs: [title],
    );
    return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
  }

  Future<int> updateModule(ModuleModel module) async {
    final db = await _db;
    return db.update(
      Tables.modules,
      module.toMap(),
      where: '${ModuleFields.id} = ?',
      whereArgs: [module.id],
    );
  }

  Future<int> deleteModule(int id) async {
    final db = await _db;
    return db.delete(
      Tables.modules,
      where: '${ModuleFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getNumberOfModules() async {
    final db = await _db;
    final result =
    await db.rawQuery('SELECT COUNT(*) AS count FROM ${Tables.modules}');
    return (result.first['count'] as int?) ?? 0;
  }
}
