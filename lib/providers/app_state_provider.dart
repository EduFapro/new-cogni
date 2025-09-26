import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppState {
  splash,
  welcome,
  home,
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState.splash;
  }

  void goToWelcome() {
    state = AppState.welcome;
  }

  void goToHome() {
    state = AppState.home;
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);
