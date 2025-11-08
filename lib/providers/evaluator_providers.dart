import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/evaluator/data/evaluator_model.dart';

final currentUserProvider =
NotifierProvider<CurrentUserNotifier, EvaluatorModel?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends Notifier<EvaluatorModel?> {
  @override
  EvaluatorModel? build() => null;

  void setUser(EvaluatorModel? user) => state = user;
  void clearUser() => state = null;
}
