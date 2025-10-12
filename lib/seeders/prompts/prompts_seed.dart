library prompts_seeds;

import '../../core/logger/app_logger.dart';
import '../../features/task_prompt/data/task_prompt_local_datasource.dart';
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

Future<void> seedPrompts() async {
  final datasource = TaskPromptLocalDataSource();

  for (final prompt in tasksPromptsList) {
    final exists = await datasource.exists(prompt.promptID.toString());
    if (!exists) {
      await datasource.insert(prompt.toModel());
      AppLogger.seed('Seeded prompt: ${prompt.promptID} → ${prompt.filePath}');
    } else {
      AppLogger.debug('Skipped existing prompt: ${prompt.promptID}');
    }
  }
}
