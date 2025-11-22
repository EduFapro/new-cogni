import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:segundo_cogni/features/task_instance/domain/video_record_task_view.dart';
import 'package:segundo_cogni/features/task_instance/domain/video_task_view.dart';

import 'image_record_task_view.dart';
import 'lib/features/task_instance/providers/task_instance_providers.dart';



class TaskRunnerScreen extends ConsumerWidget {
  final int taskInstanceId;

  const TaskRunnerScreen({super.key, required this.taskInstanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskInstanceAsync =
    ref.watch(taskInstanceByIdProvider(taskInstanceId));

    return taskInstanceAsync.when(
      data: (taskInstance) {
        final task = taskInstance.task;

        if (task.videoPath != null && task.taskMode.isPlay) {
          return VideoTaskView(task: task, instance: taskInstance);
        }

        if (task.videoPath != null && task.taskMode.isRecord) {
          return VideoRecordTaskView(task: task, instance: taskInstance);
        }

        if (task.imagePath != null && task.taskMode.isRecord) {
          return ImageRecordTaskView(task: task, instance: taskInstance);
        }

        return const Center(child: Text("⚠ Unsupported task type"));
      },
      loading: () => const Center(child: ProgressRing()),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}
