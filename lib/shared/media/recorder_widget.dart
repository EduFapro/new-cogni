import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderWidget extends StatefulWidget {
  final void Function(File recordingFile, Duration duration)?
  onRecordingFinished;
  final VoidCallback? onQuit;
  final bool autoStart;

  const RecorderWidget({
    super.key,
    this.onRecordingFinished,
    this.onQuit,
    this.autoStart = false,
  });

  @override
  State<RecorderWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> {
  late final AudioRecorder _recorder;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isBusy = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
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
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        // Create Cognivoice folder if it doesn't exist
        final cognivoiceDir = Directory('${dir.path}/Cognivoice');
        if (!await cognivoiceDir.exists()) {
          await cognivoiceDir.create(recursive: true);
        }

        // Save temp file inside Cognivoice folder
        final path =
            '${cognivoiceDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await _recorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _elapsed = Duration.zero;
        });

        _startTimer();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _pauseRecording() async {
    if (!_isRecording || _isPaused) return;

    try {
      await _recorder.pause();
      _timer?.cancel();
      setState(() => _isPaused = true);
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    if (!_isRecording || !_isPaused) return;

    try {
      await _recorder.resume();
      setState(() => _isPaused = false);
      _startTimer();
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final path = await _recorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      if (path != null && widget.onRecordingFinished != null) {
        widget.onRecordingFinished!(File(path), _elapsed);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0078D4).withOpacity(0.95),
            const Color(0xFF005A9E).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRecording) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isPaused
                          ? Colors.orange
                          : const Color(0xFFE81123),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  _isRecording
                      ? (_isPaused ? 'Pausado' : 'Gravando...')
                      : 'Pronto para gravar',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _format(_elapsed),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quit Button (Only visible when paused)
                if (_isPaused) ...[
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(Colors.red.dark),
                      padding: ButtonState.all(
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    onPressed: widget.onQuit,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(FluentIcons.cancel, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SAIR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Pause/Resume Button (Only visible when recording)
                if (_isRecording) ...[
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(Colors.white),
                      foregroundColor: ButtonState.all(const Color(0xFF0078D4)),
                      padding: ButtonState.all(
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPaused ? FluentIcons.play : FluentIcons.pause,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPaused ? 'RETOMAR' : 'PAUSAR',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Stop/Start Button
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(
                      _isRecording ? const Color(0xFFE81123) : Colors.white,
                    ),
                    foregroundColor: ButtonState.all(
                      _isRecording ? Colors.white : const Color(0xFF0078D4),
                    ),
                    padding: ButtonState.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  onPressed: _isBusy
                      ? null
                      : _isRecording
                      ? _stopRecording
                      : _startRecording,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecording
                            ? FluentIcons.stop
                            : FluentIcons.microphone,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isRecording ? 'PARAR' : 'GRAVAR',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
