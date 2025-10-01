import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import '../seeders/modules/modules_seeds.dart';
// import '../seeders/prompts_seeder/prompts_seeds.dart';
// import '../seeders/tasks/task_seeds.dart';

import 'features/evaluation/data/evaluation_constants.dart';
import 'features/evaluator/data/evaluator_constants.dart';
import 'features/participant/data/participant_constants.dart';
import 'core/constants/database_constants.dart';
// import 'recording_file/recording_file_constants.dart';
// import 'task/task_constants.dart';
// import 'task_instance/task_instance_constants.dart';
// import 'task_prompt/task_prompt_constants.dart';
// import 'evaluator/evaluator_constants.dart';
// import 'module/module_constants.dart';
// import 'module_instance/module_instance_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, DatabaseConfig.name);
      print("Database path: $path");

      var db = await openDatabase(
        path,
        version: DatabaseConfig.version,
        onCreate: _onCreate,
      );

      // 🔑 Enable foreign key enforcement
      await db.execute("PRAGMA foreign_keys = ON;");

      print("Database initialized with foreign keys enabled");
      return db;
    } catch (e) {
      print("Error initializing database: $e");
      throw e;
    }
  }

  Future<bool> isAdminConfigured() async {
    final db = await this.db;
    var result = await db.query(
      Tables.evaluators,
      where: "${EvaluatorFields.isAdmin} = ?",
      whereArgs: [1],
    );
    return result.isNotEmpty;
  }

  void _onCreate(Database db, int newVersion) async {
    try {
      await db.execute(scriptCreateTableEvaluators);
      await db.execute(scriptCreateTableParticipants);
      await db.execute(scriptCreateTableEvaluations);
      // await db.execute(scriptCreateTableModules);
      // await db.execute(scriptCreateTableTasks);
      // await db.execute(scriptCreateTableModuleInstances);
      // await db.execute(scriptCreateTableTaskInstances);
      // await db.execute(scriptCreateTableTaskPrompt);
      // await db.execute(scriptCreateTableRecordings);
      // insertInitialData();
    } catch (e) {
      print("Error creating tables: $e");
      throw e;
    }
  }

// Future<void> insertInitialData() async {
//   final db = await this.db;
//   for (var module in modulesList) {
//     await db.insert(Tables.modules, module.toMap());
//   }
//   for (var task in tasksList) {
//     await db.insert(Tables.tasks, task.toMap());
//   }
//   for (var taskPrompt in tasksPromptsList) {
//     await db.insert(Tables.prompts, taskPrompt.toMap());
//   }
//   // print("Config.adminMap: ${Config.adminMap}");
//   // try {
//   //   await db.insert(Tables.evaluators, Config.adminMap);
//   // } catch (e) {
//   //   "NÃO DEU P INSERIR NO BD $e";
//   //   "Config.adminMap: ${Config.adminMap}";
//   // }
// }
}
