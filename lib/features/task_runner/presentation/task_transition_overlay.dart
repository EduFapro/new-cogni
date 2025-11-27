import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

class TaskTransitionOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final int seconds;

  const TaskTransitionOverlay({
    super.key,
    required this.onComplete,
    this.seconds = 3,
  });

  @override
  State<TaskTransitionOverlay> createState() => _TaskTransitionOverlayState();
}

class _TaskTransitionOverlayState extends State<TaskTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late int _currentCount;
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.seconds;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
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
        _fadeController.reverse().then((_) {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Acrylic(
          tint: const Color(0xFF0078D4),
          blurAmount: 20,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FluentIcons.forward, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Próxima tarefa em $_currentCount segundo${_currentCount > 1 ? 's' : ''}...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
