import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../../shared/media/recorder_widget.dart';
import '../../../../shared/media/task_video_background_media_kit.dart';
import 'task_shell.dart';

class MediaRecordTaskScreen extends StatefulWidget {
  final String videoAssetPath;
  final void Function(String recordingPath, Duration duration)?
  onRecordingFinished;

  const MediaRecordTaskScreen({
    super.key,
    required this.videoAssetPath,
    this.onRecordingFinished,
  });

  @override
  State<MediaRecordTaskScreen> createState() => _MediaRecordTaskScreenState();
}

class _MediaRecordTaskScreenState extends State<MediaRecordTaskScreen> {
  bool _videoCompleted = false;

  void _onVideoCompleted() {
    setState(() {
      _videoCompleted = true;
    });
  }

  void _onRecordingFinished(File file, Duration duration) {
    // Call the callback immediately (no countdown)
    widget.onRecordingFinished?.call(file.path, duration);
  }

  @override
  Widget build(BuildContext context) {
    Widget? bottomOverlay;

    if (_videoCompleted) {
      // Mostra recorder widget
      bottomOverlay = RecorderWidget(
        autoStart: true,
        onRecordingFinished: _onRecordingFinished,
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
