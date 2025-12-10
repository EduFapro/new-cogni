import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'media_providers.dart';

/// Background video widget using media_kit.
///
/// [assetPath] should be the **Flutter asset path**, e.g:
/// `assets/video/task_prompts/0101-ola_tudo_bem.mp4`
///
/// This widget:
/// - Plays the video as a background
/// - Can loop or call [onCompleted] once at the end
/// - Can auto-play or wait for manual control (via [autoPlay])
class TaskVideoBackgroundMediaKit extends ConsumerStatefulWidget {
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
  ConsumerState<TaskVideoBackgroundMediaKit> createState() =>
      _TaskVideoBackgroundMediaKitState();
}

class _TaskVideoBackgroundMediaKitState
    extends ConsumerState<TaskVideoBackgroundMediaKit> {
  VideoController? _controller;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<bool>? _playingSub;
  bool _completedNotified = false;
  double _opacity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ref.watch(backgroundVideoControllerProvider);
    if (_controller != controller) {
      _controller = controller;
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    if (_controller == null) return;

    final player = _controller!.player;

    // Reset subscriptions
    _completedSub?.cancel();
    _playingSub?.cancel();

    // Configure looping behavior
    if (widget.loop) {
      player.setPlaylistMode(PlaylistMode.loop);
    } else {
      player.setPlaylistMode(PlaylistMode.none);
      _completedSub = player.stream.completed.listen(_handleCompleted);
    }

    // Listen to playing state
    _playingSub = player.stream.playing.listen(_handlePlayingStateChanged);

    _openAsset();
  }

  Future<void> _openAsset() async {
    if (_controller == null) return;

    final uri = 'asset:///${widget.assetPath}';
    try {
      await _controller!.player.open(Media(uri), play: widget.autoPlay);
    } catch (e) {
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

  void _handlePlayingStateChanged(bool isPlaying) {
    if (isPlaying && _opacity == 0.0 && mounted) {
      setState(() {
        _opacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    _playingSub?.cancel();
    // DO NOT dispose the player/controller here as it is shared.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: Video(controller: _controller!, controls: null, fit: BoxFit.cover),
    );
  }
}
