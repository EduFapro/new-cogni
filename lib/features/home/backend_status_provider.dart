import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/network.dart';
import '../../providers/network_provider.dart';
import '../../providers/providers.dart';

enum BackendStatus { checking, connected, disconnected }

class BackendStatusNotifier extends Notifier<BackendStatus> {
  @override
  BackendStatus build() {
    // Trigger initial check
    Future.microtask(() => checkStatus());
    return BackendStatus.checking;
  }

  Future<void> checkStatus() async {
    state = BackendStatus.checking;
    try {
      final networkService = ref.read(networkServiceProvider);
      final result = await networkService.checkBackendStatus();
      if (result != null && result['status'] == 'ok') {
        state = BackendStatus.connected;
      } else {
        state = BackendStatus.disconnected;
      }
    } catch (_) {
      state = BackendStatus.disconnected;
    }
  }
}

final backendStatusProvider =
    NotifierProvider<BackendStatusNotifier, BackendStatus>(
      BackendStatusNotifier.new,
    );
