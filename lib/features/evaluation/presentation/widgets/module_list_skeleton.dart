import 'package:fluent_ui/fluent_ui.dart';
import '../../../../shared/widgets/skeleton.dart';

class ModuleListSkeleton extends StatelessWidget {
  const ModuleListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header Skeleton
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Skeleton(height: 24)),
              SizedBox(width: 8),
              Expanded(flex: 2, child: Skeleton(height: 24)),
              SizedBox(width: 8),
              Expanded(flex: 2, child: Skeleton(height: 24)),
            ],
          ),
        ),
        const Divider(),

        // Table Rows Skeleton
        Expanded(
          child: ListView.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, __) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Skeleton(height: 20)),
                    SizedBox(width: 8),
                    Expanded(flex: 2, child: Skeleton(height: 20)),
                    SizedBox(width: 8),
                    Expanded(flex: 2, child: Skeleton(height: 20)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
