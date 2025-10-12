library task_seeds;

import '../../core/logger/app_logger.dart';
import '../../core/constants/enums/task_mode.dart';
import '../../features/task/data/task_local_datasource.dart';
import '../../features/task/data/task_model.dart';
import '../../features/task/domain/task_entity.dart';
import '../modules/modules_seeds.dart';

// 👇 These are your part files — they must NOT import anything themselves
part 'task_seeds_constants.dart';
part 'task_seeds_list.dart';

Future<void> seedTasks() async {
  final datasource = TaskLocalDataSource();

  for (final task in tasksList) {
    final exists = await datasource.exists(task.taskID?.toString() ?? '${task.moduleID}-${task.title}');
    if (!exists) {
      // adjust depending on your data layer
      await datasource.insertTask(task.toModel());
      AppLogger.seed('Seeded task: ${task.title} (module ${task.moduleID})');
    } else {
      AppLogger.debug('Skipped existing task: ${task.title}');
    }
  }
}
extension TaskEntityMapper on TaskEntity {
  TaskModel toModel() {
    return TaskModel(
      taskID: taskID,
      moduleID: moduleID,
      title: title,
      transcript: transcript,
      taskMode: taskMode,
      position: position,
      imagePath: imagePath,
      timeForCompletion: timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt,
      testOnly: testOnly,
    );
  }
}