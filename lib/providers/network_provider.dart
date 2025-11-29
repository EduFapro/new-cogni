import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});
