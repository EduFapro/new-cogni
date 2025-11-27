import 'package:fluent_ui/fluent_ui.dart';

class TaskShell extends StatelessWidget {
  final Widget background;      // video or image, full screen
  final Widget? centerOverlay;  // prompts, buttons, etc.
  final Widget? bottomOverlay;  // recorder / next button

  const TaskShell({
    super.key,
    required this.background,
    this.centerOverlay,
    this.bottomOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Stack(
        children: [
          // full-screen background
          Positioned.fill(child: background),

          if (centerOverlay != null)
            Align(
              alignment: Alignment.center,
              child: centerOverlay!,
            ),

          if (bottomOverlay != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: bottomOverlay!,
              ),
            ),
        ],
      ),
    );
  }
}
