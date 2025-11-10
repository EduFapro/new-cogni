import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/logger/app_logger.dart';
import '../core/database_helper.dart';
import 'modules/modules_seeds.dart';
import 'tasks/task_seeds.dart';
import 'prompts/prompts_seed.dart';
import 'evaluators/evaluator_seed.dart';

class SeedRunner {
  /// Runs all database seeders in a controlled order.
  /// You can call this without parameters — it will automatically open the DB.
  Future<void> run({Database? db}) async {
    AppLogger.seed('Starting database seeding...');
    final database = db ?? await DatabaseHelper.instance.database;

    try {
      await seedModules(database);
      await seedTasks(database);
      await seedPrompts(database);
      await seedDummyEvaluator(database);

      AppLogger.seed('✅ Database seeding complete.');
    } catch (e, s) {
      AppLogger.error('❌ Database seeding failed', e, s);
      rethrow;
    }
  }
}
