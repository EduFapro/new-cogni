import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderWidget extends StatefulWidget {
  final void Function(File recordingFile)? onRecordingFinished;
  final bool autoStart;

  const RecorderWidget({
    super.key,
    this.onRecordingFinished,
    this.autoStart = false,
  });

  @override
  State<RecorderWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isBusy = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _currentPath;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _startRecording();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isBusy || _isRecording) return;
    setState(() => _isBusy = true);

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        // You can show a dialog here if you want.
        setState(() => _isBusy = false);
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'rec_${DateTime.now().millisecondsSinceEpoch.toString()}.m4a';
      final path = '${dir.path}/$fileName';
      _currentPath = path;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _elapsed = Duration.zero;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });

      setState(() {
        _isRecording = true;
        _isBusy = false;
      });
    } catch (e) {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _stopRecording() async {
    if (_isBusy || !_isRecording) return;
    setState(() => _isBusy = true);

    try {
      final path = await _recorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _isBusy = false;
      });

      if (path != null && widget.onRecordingFinished != null) {
        widget.onRecordingFinished!(File(path));
      }
    } catch (_) {
      setState(() => _isBusy = false);
    }
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Acrylic(
      tint: Colors.black,
      blurAmount: 15,
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big round record button
            Button(
              style: ButtonStyle(
                shape: ButtonState.all(const CircleBorder()),
                padding: ButtonState.all(const EdgeInsets.all(18)),
              ),
              onPressed: _isBusy
                  ? null
                  : _isRecording
                  ? _stopRecording
                  : _startRecording,
              child: Icon(
                _isRecording ? FluentIcons.stop : FluentIcons.mic,
                size: 24,
                color: theme.resources.textOnAccentFillColorPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRecording ? 'Gravando...' : 'Pronto para gravar',
                  style: theme.typography.bodyStrong,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(_elapsed),
                  style: theme.typography.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
