import 'package:fluent_ui/fluent_ui.dart';

import '../../../../shared/media/recorder_widget.dart';
import '../../../../shared/media/task_image_background.dart';
import 'task_shell.dart';

class ImageRecordTaskScreen extends StatelessWidget {
  final String imageAssetPath;
  final void Function(String recordingPath, Duration duration)?
  onRecordingFinished;

  const ImageRecordTaskScreen({
    super.key,
    required this.imageAssetPath,
    this.onRecordingFinished,
  });

  @override
  Widget build(BuildContext context) {
    return TaskShell(
      background: TaskImageBackground(assetPath: imageAssetPath),
      bottomOverlay: RecorderWidget(
        onRecordingFinished: (file, duration) =>
            onRecordingFinished?.call(file.path, duration),
      ),
    );
  }
}
