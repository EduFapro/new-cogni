import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../shared/media/recorder_widget.dart';
import '../../../../shared/media/task_image_background.dart';
import '../../../../shared/media/task_video_player.dart';
import 'task_shell.dart';

class ImageRecordTaskScreen extends HookWidget {
  final String imageAssetPath;
  final String? videoAssetPath;
  final void Function(String recordingPath, Duration duration)?
  onRecordingFinished;
  final Duration? maxDuration;

  const ImageRecordTaskScreen({
    super.key,
    required this.imageAssetPath,
    this.videoAssetPath,
    this.onRecordingFinished,
    this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    // If video is provided, play it first.
    final isPlayingVideo = useState(videoAssetPath != null);

    // For hover visibility
    final isHovering = useState(false);

    if (isPlayingVideo.value && videoAssetPath != null) {
      return Container(
        color: Colors.black,
        // Use TaskVideoPlayer instead of AppVideoPlayer
        child: TaskVideoPlayer(
          assetPath: videoAssetPath!,
          onCompleted: () {
            isPlayingVideo.value = false;
          },
        ),
      );
    }

    return TaskShell(
      background: TaskImageBackground(assetPath: imageAssetPath),
      // Overlay logic: if video was passed, we use the "semi-visible unless hover" mode.
      // Otherwise use normal behavior (bottom overlay).
      bottomOverlay: videoAssetPath != null
          ? MouseRegion(
              onEnter: (_) => isHovering.value = true,
              onExit: (_) => isHovering.value = false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                // Opacity 0.3 when idle (semi-visible), 1.0 when hovering
                opacity: isHovering.value ? 1.0 : 0.3,
                child: RecorderWidget(
                  onRecordingFinished: (file, duration) =>
                      onRecordingFinished?.call(file.path, duration),
                  maxDuration: maxDuration,
                ),
              ),
            )
          : RecorderWidget(
              onRecordingFinished: (file, duration) =>
                  onRecordingFinished?.call(file.path, duration),
              maxDuration: maxDuration,
            ),
    );
  }
}
