import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_player/video_player.dart';

class TaskVideoPlayer extends StatefulWidget {
  final String assetPath;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onCompleted;

  const TaskVideoPlayer({
    super.key,
    required this.assetPath,
    this.autoPlay = true,
    this.loop = false,
    this.onCompleted,
  });

  @override
  State<TaskVideoPlayer> createState() => _TaskVideoPlayerState();
}

class _TaskVideoPlayerState extends State<TaskVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isCompleted = false;

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

    _controller.addListener(_handleVideoTick);
  }

  void _handleVideoTick() {
    if (!_controller.value.isInitialized) return;
    if (widget.loop) return;

    if (_controller.value.position >= _controller.value.duration &&
        !_isCompleted) {
      _isCompleted = true;
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoTick);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: ProgressRing());
    }

    return Stack(
      children: [
        // Fullscreen background video
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // Minimal overlay controls
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Acrylic(
              tint: Colors.black,
              blurAmount: 10,
              child: IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? FluentIcons.pause
                      : FluentIcons.play,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
