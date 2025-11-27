import 'package:fluent_ui/fluent_ui.dart';

import 'task_runner_screen.dart';
import 'task_transition_overlay.dart';

class TaskTransitionWrapper extends StatefulWidget {
  final int nextTaskInstanceId;

  const TaskTransitionWrapper({super.key, required this.nextTaskInstanceId});

  @override
  State<TaskTransitionWrapper> createState() => _TaskTransitionWrapperState();
}

class _TaskTransitionWrapperState extends State<TaskTransitionWrapper> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Black screen behind the overlay
        Container(color: const Color(0xFF1A1A1A)),
        if (_showOverlay)
          TaskTransitionOverlay(
            seconds: 3,
            onComplete: () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  FluentPageRoute(
                    builder: (_) => TaskRunnerScreen(
                      taskInstanceId: widget.nextTaskInstanceId,
                    ),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
