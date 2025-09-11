import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppState {
  splash,
  welcome,
  home,
}

final appStateProvider = StateProvider<AppState>((ref) => AppState.splash);
