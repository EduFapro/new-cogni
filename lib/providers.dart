import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'features/evaluator/data/evaluator_model.dart';

enum AppEnv { local, remote }

final environmentProvider = Provider<AppEnv>((_) => AppEnv.local);


final currentUserProvider =
NotifierProvider<CurrentUserNotifier, EvaluatorModel?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<EvaluatorModel?> {
  @override
  EvaluatorModel? build() => null; // initial state is null

  void setUser(EvaluatorModel user) => state = user;

  void clearUser() => state = null;
}

