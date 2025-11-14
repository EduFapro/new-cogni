import 'package:sqflite_common/sqlite_api.dart'; // <-- to access DatabaseExecutor
import '../core/logger/app_logger.dart';
import 'modules/modules_seeds.dart';
import 'tasks/task_seeds.dart';
import 'prompts/prompts_seed.dart';
import 'evaluators/evaluator_seed.dart';

class SeedRunner {
  /// Runs all database seeders using the given database executor.
  Future<void> run({required DatabaseExecutor db}) async {
    AppLogger.seed('Starting database seeding...');

    try {
      await seedModules(db);
      await seedTasks(db);
      await seedPrompts(db);
      await seedDummyEvaluator(db);

      AppLogger.seed('✅ Database seeding complete.');
    } catch (e, s) {
      AppLogger.error('❌ Database seeding failed', e, s);
      rethrow;
    }
  }
}
