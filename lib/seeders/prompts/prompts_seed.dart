library prompts_seeds;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/logger/app_logger.dart';
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

Future<void> seedPrompts(Database db) async {
  AppLogger.seed('[PROMPTS] Seeding prompts...');

  for (final prompt in tasksPromptsList) {
    final result = await db.query(
      'task_prompts',
      where: 'promptID = ?',
      whereArgs: [prompt.promptID],
    );
    if (result.isEmpty) {
      await db.insert('task_prompts', prompt.toModel().toMap());
      AppLogger.seed('[PROMPTS] Seeded prompt: ${prompt.promptID} → ${prompt.filePath}');
    } else {
      AppLogger.debug('[PROMPTS] Skipped existing prompt: ${prompt.promptID}');
    }
  }

  AppLogger.seed('[PROMPTS] Done seeding prompts.');
}