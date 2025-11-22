import 'package:fluent_ui/fluent_ui.dart';
import 'package:segundo_cogni/features/task_instance/domain/task_instance_entity.dart';

import '../../../shared/media/recorder_widget.dart';
import '../../task/domain/task_entity.dart';

class ImageRecordTaskView extends StatelessWidget {
  final TaskEntity task;
  final TaskInstanceEntity instance;

  const ImageRecordTaskView({
    super.key,
    required this.task,
    required this.instance,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              task.imagePath!,
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: RecorderWidget(
              onRecordingFinished: (file) {
                // TODO save recording → then next task
              },
            ),
          )
        ],
      ),
    );
  }
}
