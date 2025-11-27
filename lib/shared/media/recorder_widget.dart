import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderWidget extends StatefulWidget {
  final void Function(File recordingFile, Duration duration)?
  onRecordingFinished;
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
  late final AudioRecorder _recorder;
  bool _isRecording = false;
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
        final path =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await _recorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _elapsed = Duration.zero;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _elapsed += const Duration(seconds: 1));
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _stopRecording() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final path = await _recorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording button
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isRecording
                        ? const Color(0xFFE81123).withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FilledButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const CircleBorder()),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(28)),
                  backgroundColor: WidgetStateProperty.all(
                    _isRecording ? const Color(0xFFE81123) : Colors.white,
                  ),
                ),
                onPressed: _isBusy
                    ? null
                    : _isRecording
                    ? _stopRecording
                    : _startRecording,
                child: Icon(
                  _isRecording ? FluentIcons.stop : FluentIcons.microphone,
                  size: 32,
                  color: _isRecording ? Colors.white : const Color(0xFF0078D4),
                ),
              ),
            ),
            const SizedBox(width: 32),
            // Recording info
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_isRecording) ...[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE81123),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _isRecording ? 'Gravando...' : 'Pronto para gravar',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
