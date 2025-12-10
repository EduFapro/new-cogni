import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Provides a single shared [VideoController] instance for background videos.
///
/// Sharing the controller ensures stable texture binding and prevents
/// issues with multiple controllers fighting for the same player.
final backgroundVideoControllerProvider = Provider<VideoController>((ref) {
  final player = Player();
  final controller = VideoController(player);

  // Dispose the player when the provider is finally disposed (app exit)
  ref.onDispose(() {
    player.dispose();
  });

  return controller;
});
