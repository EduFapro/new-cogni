import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';
import 'package:video_player/video_player.dart';
import '../../../shared/media/recorder_widget.dart';
import '../../../core/constants/enums/task_mode.dart';

import '../../task/domain/task_entity.dart';

class VideoRecordTaskView extends StatefulWidget {
  final TaskEntity task;
  final TaskInstanceEntity instance;
  final void Function(File? recordingFile, Duration duration) onTaskCompleted;

  const VideoRecordTaskView({
    super.key,
    required this.task,
    required this.instance,
    required this.onTaskCompleted,
  });

  @override
  State<VideoRecordTaskView> createState() => _VideoRecordTaskViewState();
}

class _VideoRecordTaskViewState extends State<VideoRecordTaskView> {
  late VideoPlayerController controller;
  bool videoCompleted = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset(widget.task.videoAssetPath!)
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });

    controller.addListener(() {
      if (controller.value.position >= controller.value.duration &&
          !videoCompleted) {
        setState(() => videoCompleted = true);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresRecording = widget.task.taskMode == TaskMode.record;

    return NavigationView(
      content: Column(
        children: [
          Expanded(
            child: controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  )
                : const ProgressRing(),
          ),

          if (videoCompleted)
            RecorderWidget(
              requiresRecording: requiresRecording,
              onRecordingFinished: (file, duration) {
                widget.onTaskCompleted(file, duration);
              },
              onNext: () {
                // For non-recording tasks, we pass null file and zero duration (or actual duration if tracked)
                widget.onTaskCompleted(null, Duration.zero);
              },
            ),
        ],
      ),
    );
  }
}
