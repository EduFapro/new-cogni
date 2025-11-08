import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/environment.dart';


final environmentProvider = Provider<AppEnv>((ref) {
  return AppEnv.local;
});
