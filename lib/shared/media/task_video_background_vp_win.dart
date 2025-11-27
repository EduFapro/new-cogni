import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_player/video_player.dart';

class TaskVideoBackgroundVideoPlayerWin extends StatefulWidget {
  final String assetPath;
  final bool loop;
  final bool autoPlay;
  final VoidCallback? onCompleted;

  const TaskVideoBackgroundVideoPlayerWin({
    super.key,
    required this.assetPath,
    this.loop = false,
    this.autoPlay = true,
    this.onCompleted,
  });

  @override
  State<TaskVideoBackgroundVideoPlayerWin> createState() =>
      _TaskVideoBackgroundVideoPlayerWinState();
}

class _TaskVideoBackgroundVideoPlayerWinState
    extends State<TaskVideoBackgroundVideoPlayerWin> {
  late VideoPlayerController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        if (widget.autoPlay) {
          _controller.play();
        }
      });

    _controller.addListener(() {
      if (!_controller.value.isInitialized) return;
      if (widget.loop) {
        if (_controller.value.position >= _controller.value.duration &&
            !_controller.value.isPlaying) {
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      } else if (_controller.value.position >=
          _controller.value.duration &&
          !_completed) {
        _completed = true;
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: ProgressRing());
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
