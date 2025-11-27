library task_seeds;

import 'package:segundo_cogni/core/constants/video_file_paths.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/database_constants.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/enums/task_mode.dart';
import '../../features/task/data/task_constants.dart';
import '../../features/task/data/task_model.dart';
import '../../features/task/domain/task_entity.dart';
import '../modules/modules_seeds.dart';

part 'task_seeds_constants.dart';
part 'task_seeds_list.dart';

Future<void> seedTasks(DatabaseExecutor db) async {
  AppLogger.seed('[TASKS] Seeding tasks...');

  for (final task in tasksList) {
    final result = await db.query(
      Tables.tasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [task.taskID],
    );

    if (result.isEmpty) {
      await db.insert(Tables.tasks, task.toModel().toMap());
      AppLogger.seed(
        '[TASKS] Seeded task: ${task.title} (module ${task.moduleID})',
      );
    } else {
      AppLogger.debug('[TASKS] Skipped existing task: ${task.title}');
    }
  }

  AppLogger.seed('[TASKS] Done seeding tasks.');
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
      imageAssetPath: imageAssetPath,
      videoAssetPath: videoAssetPath,
      timeForCompletion: timeForCompletion,
      mayRepeatPrompt: mayRepeatPrompt,
      testOnly: testOnly,
    );
  }
}
