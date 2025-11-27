import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Background video widget using media_kit.
///
/// [assetPath] should be the **Flutter asset path**, e.g:
/// `assets/video/task_prompts/0101-ola_tudo_bem.mp4`
///
/// This widget:
/// - Plays the video as a background
/// - Can loop or call [onCompleted] once at the end
/// - Can auto-play or wait for manual control (via [autoPlay])
class TaskVideoBackgroundMediaKit extends StatefulWidget {
  final String assetPath;
  final bool loop;
  final bool autoPlay;
  final VoidCallback? onCompleted;

  const TaskVideoBackgroundMediaKit({
    super.key,
    required this.assetPath,
    this.loop = false,
    this.autoPlay = true,
    this.onCompleted,
  });

  @override
  State<TaskVideoBackgroundMediaKit> createState() =>
      _TaskVideoBackgroundMediaKitState();
}

class _TaskVideoBackgroundMediaKitState
    extends State<TaskVideoBackgroundMediaKit> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<bool>? _completedSub;
  bool _completedNotified = false;

  @override
  void initState() {
    super.initState();

    _player = Player();
    _controller = VideoController(_player);

    // Configure looping behavior before opening media.
    if (widget.loop) {
      _player.setPlaylistMode(PlaylistMode.loop);
    } else {
      _completedSub = _player.stream.completed.listen(_handleCompleted);
    }

    _openAsset();
  }

  Future<void> _openAsset() async {
    final uri = 'asset:///${widget.assetPath}';
    // You can add a debug print here if needed:
    // debugPrint('🎬 Opening video asset: $uri');

    try {
      await _player.open(
        Media(uri),
        play: widget.autoPlay,
      );
    } catch (e) {
      // Avoid crashing the whole app on load failure.
      debugPrint('❌ Failed to open video asset: $uri\n$e');
    }
  }

  void _handleCompleted(bool done) {
    if (!done) return;
    if (_completedNotified) return;
    _completedNotified = true;

    if (widget.onCompleted != null && mounted) {
      widget.onCompleted!.call();
    }
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: _controller,
      controls: null,
      fit: BoxFit.cover,
    );
  }
}
