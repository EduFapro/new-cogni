import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/admin/admin_repository.dart';

enum AdminRegistrationState { idle, loading, success, error }

class AdminRegistrationNotifier extends Notifier<AdminRegistrationState> {
  late final AdminRepository _repository;

  @override
  AdminRegistrationState build() {
    _repository = AdminRepository();
    return AdminRegistrationState.idle;
  }

  Future<void> registerAdmin(Map<String, dynamic> data) async {
    state = AdminRegistrationState.loading;
    try {
      await _repository.registerAdmin(data);
      state = AdminRegistrationState.success;
    } catch (e) {
      state = AdminRegistrationState.error;
      rethrow;
    }
  }
}

final adminRegistrationProvider =
NotifierProvider<AdminRegistrationNotifier, AdminRegistrationState>(
  AdminRegistrationNotifier.new,
);
