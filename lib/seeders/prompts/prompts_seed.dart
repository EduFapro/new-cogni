library prompts_seeds;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/database_constants.dart';
import '../../core/logger/app_logger.dart';
import '../../features/task_prompt/data/task_prompt_constants.dart';
import '../../features/task_prompt/data/task_prompt_model.dart';
import '../../features/task_prompt/domain/task_prompt_entity.dart';
import '../../core/constants/audio_file_paths.dart';

import '../tasks/task_seeds.dart';

part 'prompts_seeds_constants.dart';
part 'prompts_seeds_list.dart';

extension TaskPromptEntityMapper on TaskPromptEntity {
  TaskPromptModel toModel() {
    return TaskPromptModel(
      promptID: promptID,
      taskID: taskID,
      filePath: filePath,
      transcription: transcription,
    );
  }
}

Future<void> seedPrompts(DatabaseExecutor db) async {
  AppLogger.seed('[PROMPTS] Seeding prompts...');

  for (final prompt in tasksPromptsList) {
    // 1. Check if a prompt already exists for this task (Unique Constraint on taskID)
    final existingByTask = await db.query(
      Tables.taskPrompts,
      where: '${TaskPromptFields.taskID} = ?',
      whereArgs: [prompt.taskID],
    );

    if (existingByTask.isNotEmpty) {
      final existingPromptID = existingByTask.first[TaskPromptFields.promptID];

      if (existingPromptID == prompt.promptID) {
        AppLogger.debug(
          '[PROMPTS] Skipped existing prompt: ${prompt.promptID} (Task ${prompt.taskID})',
        );
        continue;
      } else {
        // Conflict: Task has a prompt, but ID is different.
        // Delete the old one to enforce the new seed.
        await db.delete(
          Tables.taskPrompts,
          where: '${TaskPromptFields.taskID} = ?',
          whereArgs: [prompt.taskID],
        );
        AppLogger.warning(
          '[PROMPTS] Overwriting prompt for task ${prompt.taskID} (ID $existingPromptID -> ${prompt.promptID})',
        );
      }
    }

    // 2. Check if promptID exists (Primary Key) - could happen if reassigning IDs
    final existingByID = await db.query(
      Tables.taskPrompts,
      where: '${TaskPromptFields.promptID} = ?',
      whereArgs: [prompt.promptID],
    );

    if (existingByID.isNotEmpty) {
      // ID exists but taskID was different (otherwise caught in step 1).
      // Delete to avoid PK violation.
      await db.delete(
        Tables.taskPrompts,
        where: '${TaskPromptFields.promptID} = ?',
        whereArgs: [prompt.promptID],
      );
    }

    // 3. Insert
    await db.insert(Tables.taskPrompts, prompt.toModel().toMap());
    AppLogger.seed(
      '[PROMPTS] Seeded prompt: ${prompt.promptID} → ${prompt.filePath}',
    );
  }

  AppLogger.seed('[PROMPTS] Done seeding prompts.');
}
