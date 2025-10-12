import 'package:sqflite_common/sqlite_api.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/database_helper.dart';
import '../../../core/logger/app_logger.dart';
import 'module_constants.dart';
import 'module_model.dart';

class ModuleLocalDataSource {
  final dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => dbHelper.database;

  Future<int?> insertModule(ModuleModel module) async {
    AppLogger.db('Inserting module: ${module.title}');
    try {
      final db = await _db;
      final id = await db.insert(
        Tables.modules,
        module.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.db('Module inserted successfully (id=$id)');
      return id;
    } catch (e, s) {
      AppLogger.error('Error inserting module ${module.title}', e, s);
      return null;
    }
  }

  Future<List<ModuleModel>> getAllModules() async {
    AppLogger.db('Fetching all modules');
    try {
      final db = await _db;
      final maps = await db.query(Tables.modules);
      AppLogger.db('Fetched ${maps.length} modules');
      return maps.map(ModuleModel.fromMap).toList();
    } catch (e, s) {
      AppLogger.error('Error fetching modules', e, s);
      return [];
    }
  }

  Future<ModuleModel?> getModuleById(int id) async {
    AppLogger.db('Fetching module by ID: $id');
    try {
      final db = await _db;
      final result = await db.query(
        Tables.modules,
        where: '${ModuleFields.id} = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching module by ID: $id', e, s);
      return null;
    }
  }

  Future<ModuleModel?> getModuleByTitle(String title) async {
    AppLogger.db('Fetching module by title: $title');
    try {
      final db = await _db;
      final result = await db.query(
        Tables.modules,
        where: '${ModuleFields.title} = ?',
        whereArgs: [title],
      );
      return result.isNotEmpty ? ModuleModel.fromMap(result.first) : null;
    } catch (e, s) {
      AppLogger.error('Error fetching module by title: $title', e, s);
      return null;
    }
  }

  Future<int> updateModule(ModuleModel module) async {
    AppLogger.db('Updating module ID=${module.moduleID}');
    try {
      final db = await _db;
      final rows = await db.update(
        Tables.modules,
        module.toMap(),
        where: '${ModuleFields.id} = ?',
        whereArgs: [module.moduleID],
      );
      AppLogger.db('Updated $rows row(s) for module ID=${module.moduleID}');
      return rows;
    } catch (e, s) {
      AppLogger.error('Error updating module ID=${module.moduleID}', e, s);
      return 0;
    }
  }

  Future<int> deleteModule(int id) async {
    AppLogger.db('Deleting module ID=$id');
    try {
      final db = await _db;
      final count = await db.delete(
        Tables.modules,
        where: '${ModuleFields.id} = ?',
        whereArgs: [id],
      );
      AppLogger.db('Deleted $count module(s)');
      return count;
    } catch (e, s) {
      AppLogger.error('Error deleting module ID=$id', e, s);
      return 0;
    }
  }

  Future<int> getNumberOfModules() async {
    AppLogger.db('Counting modules');
    try {
      final db = await _db;
      final result =
      await db.rawQuery('SELECT COUNT(*) AS count FROM ${Tables.modules}');
      final count = (result.first['count'] as int?) ?? 0;
      AppLogger.db('Module count: $count');
      return count;
    } catch (e, s) {
      AppLogger.error('Error counting modules', e, s);
      return 0;
    }
  }

  Future<bool> exists(String moduleId) async {
    final db = await _db;
    final result = await db.query(
      'modules',
      where: 'moduleID = ?',
      whereArgs: [moduleId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

}
