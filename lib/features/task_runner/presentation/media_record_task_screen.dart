import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../../shared/media/recorder_widget.dart';
import '../../../../shared/media/task_video_background_media_kit.dart';
import '../../../../shared/widgets/transition_countdown_widget.dart';
import 'task_shell.dart';

class MediaRecordTaskScreen extends StatefulWidget {
  final String videoAssetPath;
  final void Function(String recordingPath, Duration duration)?
  onRecordingFinished;
  final Duration? maxDuration;
  final bool requiresRecording;

  const MediaRecordTaskScreen({
    super.key,
    required this.videoAssetPath,
    this.onRecordingFinished,
    this.maxDuration,
    this.requiresRecording = true,
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

  void _onNext() {
    // For non-recording tasks, pass empty path and zero duration
    widget.onRecordingFinished?.call('', Duration.zero);
  }

  Future<void> _onQuit() async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Sair da Tarefa?'),
        content: const Text(
          'Se você sair agora, o progresso desta tarefa não será salvo.\n'
          'Você poderá realizá-la novamente mais tarde.',
        ),
        actions: [
          Button(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: ButtonState.all(Colors.red.dark),
            ),
            child: const Text('Sair'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldQuit == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? bottomOverlay;

    if (_videoCompleted) {
      if (widget.requiresRecording) {
        bottomOverlay = RecorderWidget(
          autoStart: widget.requiresRecording,
          requiresRecording: widget.requiresRecording,
          onRecordingFinished: _onRecordingFinished,
          onNext: _onNext,
          onQuit: _onQuit,
          maxDuration: widget.maxDuration,
        );
      } else {
        // For non-recording tasks, show countdown before auto-advancing
        bottomOverlay = TransitionCountdownWidget(
          onComplete: _onNext,
          seconds: 3,
          showSkipButton: true,
        );
      }
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
