import 'package:fluent_ui/fluent_ui.dart';
import '../../../../shared/widgets/skeleton.dart';

class ParticipantListSkeleton extends StatelessWidget {
  const ParticipantListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar & Filter Skeleton
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              const Expanded(child: Skeleton(height: 32)),
              const SizedBox(width: 12),
              const Skeleton(width: 150, height: 32),
              const SizedBox(width: 12),
              const Skeleton(width: 120, height: 32),
            ],
          ),
        ),

        // Table Header Skeleton
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: Skeleton(height: 24)),
              SizedBox(width: 8),
              Expanded(flex: 1, child: Skeleton(height: 24)),
              SizedBox(width: 8),
              Expanded(flex: 1, child: Skeleton(height: 24)),
              SizedBox(width: 8),
              Expanded(flex: 1, child: Skeleton(height: 24)),
            ],
          ),
        ),
        const Divider(),

        // Table Rows Skeleton
        Expanded(
          child: ListView.separated(
            itemCount: 10,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, __) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Skeleton(height: 20)),
                    SizedBox(width: 8),
                    Expanded(flex: 1, child: Skeleton(height: 20)),
                    SizedBox(width: 8),
                    Expanded(flex: 1, child: Skeleton(height: 20)),
                    SizedBox(width: 8),
                    Expanded(flex: 1, child: Skeleton(height: 20)),
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
