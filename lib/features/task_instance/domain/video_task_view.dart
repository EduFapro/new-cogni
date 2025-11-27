import 'package:fluent_ui/fluent_ui.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';
import 'package:video_player/video_player.dart';

import '../../task/domain/task_entity.dart';

class VideoTaskView extends StatefulWidget {
  final TaskEntity task;
  final TaskInstanceEntity instance;

  const VideoTaskView({super.key, required this.task, required this.instance});

  @override
  State<VideoTaskView> createState() => _VideoTaskViewState();
}

class _VideoTaskViewState extends State<VideoTaskView> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset(widget.task.videoAssetPath!)
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });

    controller.addListener(() {
      if (controller.value.position >= controller.value.duration) {
        // TODO: Navigate to next task
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
    return NavigationView(
      content: Center(
        child: controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const ProgressRing(),
      ),
    );
  }
}
