import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../../core/logger/app_logger.dart';
import '../env/env_helper.dart';

class DeterministicEncryptionHelper {
  static late final encrypt.Key _key;
  static late final encrypt.IV _fixedIV;
  static bool _initialized = false;

  static void configureLogger({
    void Function(String message)? info,
    void Function(String message, Object? error, StackTrace? stack)? error,
  }) {
    // Você já usa AppLogger diretamente, então pode
    // ignorar esse hook ou manter se quiser.
  }

  static Future<void> init() async {
    if (_initialized) return;

    AppLogger.info('[EncryptionHelper] 🧩 Initializing encryption helper...');

    // Delega o carregamento do .env para o EnvHelper
    await EnvHelper.ensureInitialized();

    final key = EnvHelper.require('ENCRYPTION_KEY');
    final iv = EnvHelper.require('ENCRYPTION_IV');
    final env = EnvHelper.currentEnv;

    AppLogger.info('[EncryptionHelper] 🔍 ENV content:');
    AppLogger.info('  - ENCRYPTION_KEY: ${key.substring(0, 4)}...(hidden)');
    AppLogger.info('  - ENCRYPTION_IV: ${iv.substring(0, 4)}...(hidden)');
    AppLogger.info('  - ENV: $env');

    if (key.length != 32 || iv.length != 16) {
      throw Exception(
        'Invalid key/IV length: key must be 32 chars, iv must be 16 chars.',
      );
    }

    _key = encrypt.Key.fromUtf8(key);
    _fixedIV = encrypt.IV.fromUtf8(iv);

    _initialized = true;
    AppLogger.info(
      '[EncryptionHelper] 🔑 Encryption helper initialized successfully (ENV=$env)',
    );
  }

  /// Getter for the encryption key (for FileEncryptionHelper)
  static encrypt.Key get key {
    if (!_initialized) {
      throw Exception('EncryptionHelper not initialized. Call init() first.');
    }
    return _key;
  }

  static String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    final base64Text = base64Encode(encrypted.bytes);
    AppLogger.info('[EncryptionHelper][Encrypt] "$plainText" → $base64Text');
    return base64Text;
  }

  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(bytes)),
        iv: _fixedIV,
      );
      AppLogger.info(
        '[EncryptionHelper][Decrypt] $encryptedText → "$decrypted"',
      );
      return decrypted;
    } catch (e, s) {
      AppLogger.error(
        '[EncryptionHelper][Decrypt] 💥 Failed to decrypt: $encryptedText',
        e,
        s,
      );
      return '[DECRYPTION_FAILED]';
    }
  }

  static String hashPassword(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
