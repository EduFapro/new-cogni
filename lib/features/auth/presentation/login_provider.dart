import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';


final loginProvider =
AsyncNotifierProvider<LoginNotifier, void>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {

  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'admin@cogni.com' && password == '1234') {
      state = const AsyncData(null);
    } else {
      state = AsyncError('Credenciais inválidas', StackTrace.current);
    }
  }
}
