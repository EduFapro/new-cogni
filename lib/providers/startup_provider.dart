import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/app_database.dart';
import '../data/repositories/admin/admin.dart';

enum StartupState { initializing, needsAdmin, ready }

class StartupNotifier extends Notifier<StartupState> {
  @override
  StartupState build() {
    // default when app launches
    return StartupState.initializing;
  }

  /// Call this during app bootstrap
  Future<void> initialize() async {
    final db = await AppDatabase.instance.database;

    final hasAdmin = await AdminDao(db).hasAnyAdmin();

    if (!hasAdmin) {
      state = StartupState.needsAdmin;
    } else {
      state = StartupState.ready;
    }
  }
}

final startupProvider =
NotifierProvider<StartupNotifier, StartupState>(StartupNotifier.new);
