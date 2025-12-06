// lib/providers/environment_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/environment.dart';
import '../shared/env/env_helper.dart';

final environmentProvider = Provider<AppEnv>((ref) {
  return EnvHelper.currentEnv;
});
