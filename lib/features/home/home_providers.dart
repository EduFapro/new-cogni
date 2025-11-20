import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Controls the selected tab index of the HomeScreen
final homeNavigationProvider = NotifierProvider<HomeNavigationNotifier, int>(
  HomeNavigationNotifier.new,
);

class HomeNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
