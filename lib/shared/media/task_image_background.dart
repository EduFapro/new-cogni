import 'package:fluent_ui/fluent_ui.dart';

class TaskImageBackground extends StatelessWidget {
  final String assetPath;

  const TaskImageBackground({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
    );
  }
}
