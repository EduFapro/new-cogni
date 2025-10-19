import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/logger/app_logger.dart';
import 'modules/modules_seeds.dart';
import 'tasks/task_seeds.dart';
import 'prompts/prompts_seed.dart';
import 'evaluators/evaluator_seed.dart';

class DatabaseSeeder {
  Future<void> run(Database db) async {
    AppLogger.seed('Starting database seeding...');

    try {
      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);
      await seedDummyEvaluator(db);
      AppLogger.seed('Database seeding complete ✅');
    } catch (e, s) {
      AppLogger.error('❌ [SEED] Database seeding failed', e, s);
      rethrow;
    }
  }
}
