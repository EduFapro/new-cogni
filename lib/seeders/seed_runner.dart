import '../core/logger/app_logger.dart';
import 'modules/modules_seeds.dart';
import 'tasks/task_seeds.dart';
import 'prompts/prompts_seed.dart';

class DatabaseSeeder {
  Future<void> run() async {
    AppLogger.seed('Starting database seeding...');

    await seedModules();
    await seedTasks();
    await seedPrompts();

    AppLogger.seed('Database seeding complete.');
  }
}
