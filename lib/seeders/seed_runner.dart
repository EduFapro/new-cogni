import 'package:sqflite_common/sqlite_api.dart';
import '../core/logger/app_logger.dart';

import 'evaluators/evaluator_seed.dart';
import 'modules/modules_seeds.dart';
import 'tasks/task_seeds.dart';

class SeedRunner {
  const SeedRunner();

  /// Run all seeders using the provided [db] (Database or Transaction).
  ///
  /// The caller is responsible for wrapping this in a transaction if atomicity
  /// is desired. All seeding steps use this same DatabaseExecutor.
  Future<void> run({required DatabaseExecutor db}) async {
    AppLogger.seed('🚀 Starting seed runner with shared executor...');

    try {
      // Order matters if there are FKs:
      await seedModules(db);
      await seedTasks(db);
      await seedTaskPrompts(db);
      await seedDummyEvaluator(db);
      // await seedWhateverElse(db);

      AppLogger.seed('✅ Seed runner completed successfully.');
    } catch (e, s) {
      AppLogger.error('❌ Seed runner failed', e, s);
      rethrow; // Let the caller/transaction handle rollback.
    }
  }
}
