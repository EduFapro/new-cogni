import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderWidget extends StatefulWidget {
  final void Function(File recordingFile, Duration duration)?
  onRecordingFinished;
  final VoidCallback? onQuit;
  final VoidCallback? onNext;
  final bool autoStart;
  final bool requiresRecording;
  final Duration? maxDuration;

  const RecorderWidget({
    super.key,
    this.onRecordingFinished,
    this.onQuit,
    this.onNext,
    this.autoStart = false,
    this.requiresRecording = true,
    this.maxDuration,
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

  // Track file for cleanup
  String? _currentFilePath;
  bool _isFinished = false;
  bool _showTimeoutMessage = false;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
    if (widget.autoStart && widget.requiresRecording) {
      // Optimistically set state to avoid "Pronto para gravar" flash
      _isRecording = true;
      _isBusy = true;
      _startRecording();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _cleanupTempFile();
    super.dispose();
  }

  void _cleanupTempFile() {
    if (!_isFinished && _currentFilePath != null) {
      try {
        final file = File(_currentFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
          debugPrint('🧹 Deleted temp recording: $_currentFilePath');
        }
      } catch (e) {
        debugPrint('Error cleaning up temp file: $e');
      }
    }
  }

  Future<void> _startRecording() async {
    // If already busy but not from auto-start (which sets busy manually), return.
    // We handle auto-start specifically.
    if (_isBusy && !widget.autoStart) return;

    // If not auto-start, set busy. If auto-start, it's already busy.
    if (!widget.autoStart) setState(() => _isBusy = true);

    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        // Create Cognivoice folder if it doesn't exist
        final cognivoiceDir = Directory('${dir.path}/Cognivoice');
        if (!await cognivoiceDir.exists()) {
          await cognivoiceDir.create(recursive: true);
        }

        // Save temp file inside Cognivoice folder with hidden prefix
        final path =
            '${cognivoiceDir.path}/.recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await _recorder.start(config, path: path);

        if (mounted) {
          setState(() {
            _isRecording = true;
            _isPaused = false;
            _elapsed = Duration.zero;
            _currentFilePath = path;
            _isFinished = false;
            _isBusy = false; // Clear busy after start
            _showTimeoutMessage = false;
          });
          _startTimer();
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        setState(() {
          _isRecording = false; // Revert if failed
          _isBusy = false;
        });
      }
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

      if (widget.maxDuration != null && _elapsed >= widget.maxDuration!) {
        _stopRecording(isTimeout: true);
      }
    });
  }

  Future<void> _stopRecording({bool isTimeout = false}) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final path = await _recorder.stop();
      _timer?.cancel();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _isFinished = true; // Mark as finished to prevent cleanup
          if (isTimeout) {
            _showTimeoutMessage = true;
          }
        });
      }

      if (isTimeout) {
        // Wait 2 seconds before calling callback
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _showTimeoutMessage = false);
        }
      }

      if (path != null && widget.onRecordingFinished != null) {
        widget.onRecordingFinished!(File(path), _elapsed);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (_showTimeoutMessage) {
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
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.timer, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Tempo esgotado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalizando gravação...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_isFinished) return const SizedBox.shrink();

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
            if (widget.requiresRecording) ...[
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
            ],

            // Controls
            Row(
              mainAxisAlignment: widget.requiresRecording
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.center, // Kept center as base
              children: [
                if (!widget.requiresRecording) ...[
                  // Next Button for non-recording tasks
                  const SizedBox(width: 40), // Push slightly right?
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(Colors.white),
                      foregroundColor: ButtonState.all(const Color(0xFF0078D4)),
                      shape: ButtonState.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Squared
                        ),
                      ),
                      padding: ButtonState.all(
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    onPressed: widget.onNext,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'PRÓXIMO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(FluentIcons.chevron_right, size: 16),
                      ],
                    ),
                  ),
                ] else ...[
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
                        foregroundColor: ButtonState.all(
                          const Color(0xFF0078D4),
                        ),
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
                        _isRecording ? const Color(0xFF107C10) : Colors.white,
                      ),
                      foregroundColor: ButtonState.all(
                        _isRecording ? Colors.white : const Color(0xFF0078D4),
                      ),
                      padding: ButtonState.all(
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
                              ? FluentIcons.check_mark
                              : FluentIcons.microphone,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? 'CONCLUIR' : 'GRAVAR',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
