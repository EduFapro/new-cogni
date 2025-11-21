// lib/providers/environment_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/environment.dart';
import '../shared/env/env_helper.dart';

final environmentProvider = Provider<AppEnv>((ref) {
  final envName = EnvHelper.currentEnv;

  switch (envName) {
    case 'remote':
    case 'prod':
    case 'production':
      return AppEnv.remote;

    case 'local':
    default:
      return AppEnv.local;
  }
});
