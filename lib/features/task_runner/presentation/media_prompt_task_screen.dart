import 'package:fluent_ui/fluent_ui.dart';

import '../../../../shared/media/task_video_background_media_kit.dart';
import '../../../../shared/widgets/transition_countdown_widget.dart';
import 'task_shell.dart';

class MediaPromptTaskScreen extends StatefulWidget {
  final String videoAssetPath;
  final VoidCallback? onCompleted;

  const MediaPromptTaskScreen({
    super.key,
    required this.videoAssetPath,
    this.onCompleted,
  });

  @override
  State<MediaPromptTaskScreen> createState() => _MediaPromptTaskScreenState();
}

class _MediaPromptTaskScreenState extends State<MediaPromptTaskScreen> {
  bool _videoCompleted = false;
  bool _showingTransition = false;

  void _onVideoCompleted() {
    setState(() {
      _videoCompleted = true;
      _showingTransition = true;
    });
  }

  void _onTransitionComplete() {
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget? bottomOverlay;

    if (_showingTransition) {
      bottomOverlay = TransitionCountdownWidget(
        onComplete: _onTransitionComplete,
        seconds: 3,
      );
    }

    return TaskShell(
      background: TaskVideoBackgroundMediaKit(
        assetPath: widget.videoAssetPath,
        onCompleted: _onVideoCompleted,
      ),
      bottomOverlay: bottomOverlay,
    );
  }
}
