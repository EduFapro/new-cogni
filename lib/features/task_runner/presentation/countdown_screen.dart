import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

class CountdownScreen extends StatefulWidget {
  final Widget targetWidget;
  final int countdownSeconds;
  final String? message;
  final Color? backgroundColor;

  const CountdownScreen({
    super.key,
    required this.targetWidget,
    this.countdownSeconds = 5,
    this.message,
    this.backgroundColor,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  late int _currentCount;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.countdownSeconds;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _animationController.forward(from: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        setState(() {
          _currentCount--;
        });
        _animationController.forward(from: 0);
      } else {
        timer.cancel();
        _navigateToTarget();
      }
    });
  }

  void _navigateToTarget() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        FluentPageRoute(builder: (_) => widget.targetWidget),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? const Color(0xFF1A1A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
            ],
            ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                _currentCount.toString(),
                style: const TextStyle(
                  fontSize: 120,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Prepare-se...',
              style: TextStyle(fontSize: 18, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}
