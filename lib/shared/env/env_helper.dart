// lib/shared/env/env_helper.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/environment.dart';

class EnvHelper {
  static bool _initialized = false;

  /// Garante que o dotenv está carregado.
  ///
  /// No app Flutter, a gente vai chamar isso indiretamente via
  /// DeterministicEncryptionHelper.init(), que por sua vez chama
  /// EnvHelper.ensureInitialized().
  static Future<void> ensureInitialized() async {
    if (_initialized && dotenv.isInitialized) return;

    if (!dotenv.isInitialized) {
      // Para Flutter: .env listado como asset no pubspec.yaml
      await dotenv.load(fileName: '.env');
    }

    _initialized = true;
  }

  /// Recupera uma env var, ou null se não existir.
  static String? get(String key) => dotenv.env[key];

  /// Recupera uma env var obrigatória (lança se não existir ou estiver vazia).
  static String require(String key) {
    final value = get(key);
    if (value == null || value.isEmpty) {
      throw Exception('EnvHelper: Missing required env var "$key" in .env');
    }
    return value;
  }

  /// Nome do ambiente (default = "local").
  static AppEnv get currentEnv {
    final mode = (dotenv.env['APP_MODE'] ?? 'local').toLowerCase();
    return switch (mode) {
      'offline' => AppEnv.offline,
      'remote' => AppEnv.remote,
      _ => AppEnv.local,
    };
  }
}
