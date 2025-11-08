import 'package:sqflite_common/sqlite_api.dart';
import '../../features/evaluator/data/current_user_constants.dart';
import '../constants/database_constants.dart';
import 'package:segundo_cogni/core/logger/app_logger.dart';

// Import table scripts
import '../../features/evaluator/data/evaluator_constants.dart';
import '../../features/module/data/module_constants.dart';
import '../../features/module_instance/data/module_instance_constants.dart';
import '../../features/participant/data/participant_constants.dart';
import '../../features/evaluation/data/evaluation_constants.dart';
import '../../features/recording_file/data/recording_file_constants.dart';
import '../../features/task/data/task_constants.dart';
import '../../features/task_instance/data/task_instance_constants.dart';
import '../../features/task_prompt/data/task_prompt_constants.dart';

class DatabaseSchema {
  static final List<String> _createScripts = [
    scriptCreateTableEvaluators,
    scriptCreateTableParticipants,
    scriptCreateTableModules,
    scriptCreateTableTasks,
    scriptCreateTableTaskPrompts,
    scriptCreateTableEvaluations,
    scriptCreateTableModuleInstances,
    scriptCreateTableTaskInstances,
    scriptCreateTableRecordings,
    scriptCreateTableCurrentUser
  ];

  static final List<String> _tableNames = [
    Tables.evaluators,
    Tables.participants,
    Tables.modules,
    Tables.tasks,
    Tables.taskPrompts,
    Tables.evaluations,
    Tables.moduleInstances,
    Tables.taskInstances,
    Tables.recordings,
    Tables.currentUser
  ];

  /// Creates all tables and verifies that they were created successfully.
  static Future<void> createAll(Database db) async {
    for (int i = 0; i < _createScripts.length; i++) {
      final tableName = _tableNames[i];
      final script = _createScripts[i];
      try {
        await db.execute(script);
        AppLogger.db('✅ Created table: $tableName');
      } catch (e) {
        AppLogger.db('⚠️ Skipping table "$tableName" — possibly already exists: $e');
      }
    }
    await _verifySchema(db);
  }

  /// Drops all tables (for upgrades or tests).
  static Future<void> dropAll(Database db) async {
    for (final name in _tableNames.reversed) {
      try {
        await db.execute('DROP TABLE IF EXISTS $name');
        AppLogger.db('🗑️ Dropped table: $name');
      } catch (e) {
        AppLogger.db('⚠️ Failed to drop $name: $e');
      }
    }
  }

  /// Confirms that all expected tables exist in the DB.
  static Future<void> _verifySchema(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    final existing = result.map((e) => e['name']).toSet();

    for (final expected in _tableNames) {
      if (existing.contains(expected)) {
        AppLogger.db('✅ Verified: $expected');
      } else {
        AppLogger.error('❌ Missing table: $expected');
      }
    }
  }
}
