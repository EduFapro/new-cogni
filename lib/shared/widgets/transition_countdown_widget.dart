import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

/// Widget de countdown simples que aparece como overlay
class TransitionCountdownWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final int seconds;

  const TransitionCountdownWidget({
    super.key,
    required this.onComplete,
    this.seconds = 3,
  });

  @override
  State<TransitionCountdownWidget> createState() =>
      _TransitionCountdownWidgetState();
}

class _TransitionCountdownWidgetState extends State<TransitionCountdownWidget> {
  late int _currentCount;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.seconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        setState(() {
          _currentCount--;
        });
      } else {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.forward, color: Colors.white, size: 32),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Próxima tarefa em',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_currentCount',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
