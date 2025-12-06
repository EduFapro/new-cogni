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
      // Mostra recorder widget
      bottomOverlay = RecorderWidget(
        autoStart: true,
        onRecordingFinished: _onRecordingFinished,
        onQuit: _onQuit,
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
