import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import '../seeders/modules/modules_seeds.dart';
// import '../seeders/prompts_seeder/prompts_seeds.dart';
// import '../seeders/tasks/task_seeds.dart';
import '../features/evaluator/data/evaluator_constants.dart';
import 'database_constants.dart';
// import 'participant/participant_constants.dart';
// import 'recording_file/recording_file_constants.dart';
// import 'task/task_constants.dart';
// import 'task_instance/task_instance_constants.dart';
// import 'task_prompt/task_prompt_constants.dart';
// import 'evaluation/evaluation_constants.dart';
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
      String path = join(databasesPath, DATABASE_NAME);
      print("Database path: $path");

      var db = await openDatabase(path,
          version: DATABASE_VERSION, onCreate: _onCreate);
      print("Database initialized");
      return db;
    } catch (e) {
      print("Error initializing database: $e");
      throw e;
    }
  }

  Future<bool> isAdminConfigured() async {
    final db = await this.db;
    var result = await db.query(TABLE_EVALUATORS, where: "is_admin = ?", whereArgs: [1]);
    return result.isNotEmpty;
  }

  void _onCreate(Database db, int newVersion) async {
    try {
      await db.execute(SCRIPT_CREATE_TABLE_EVALUATORS);
      // await db.execute(SCRIPT_CREATE_TABLE_PARTICIPANTS);
      // await db.execute(SCRIPT_CREATE_TABLE_EVALUATIONS);
      // await db.execute(SCRIPT_CREATE_TABLE_MODULES);
      // await db.execute(SCRIPT_CREATE_TABLE_TASKS);
      // await db.execute(SCRIPT_CREATE_TABLE_MODULE_INSTANCES);
      // await db.execute(SCRIPT_CREATE_TABLE_TASK_INSTANCES);
      // await db.execute(SCRIPT_CREATE_TABLE_TASK_PROMPT);
      // await db.execute(SCRIPT_CREATE_TABLE_RECORDINGS);
      // insertInitialData();
    } catch (e) {
      print("Error creating tables: $e");
      throw e;
    }
  }

  // Future<void> insertInitialData() async {
  //   final db = await this.db;
  //   for (var module in modulesList) {
  //     await db.insert(TABLE_MODULES, module.toMap());
  //   }
  //   for (var task in tasksList) {
  //     await db.insert(TABLE_TASKS, task.toMap());
  //   }
  //   for (var taskPrompt in tasksPromptsList) {
  //     await db.insert(TABLE_TASK_PROMPTS, taskPrompt.toMap());
  //   }
  //   // print("Config.adminMap: ${Config.adminMap}");
  //   // try {
  //   //   await db.insert(TABLE_EVALUATORS, Config.adminMap);
  //   // } catch (e) {
  //   //   "NÃO DEU P INSERIR NO BD $e";
  //   //   "Config.adminMap: ${Config.adminMap}";
  //   // }
  // }
}