import 'package:hooks_riverpod/hooks_riverpod.dart';

final taskInstanceByIdProvider =
FutureProvider.family<TaskInstanceWithTask, int>((ref, id) {
  final repo = ref.read(taskInstanceRepositoryProvider);
  return repo.getInstanceWithTask(id);
});
