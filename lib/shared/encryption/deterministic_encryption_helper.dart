// lib/shared/encryption/deterministic_encryption_helper.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shared deterministic AES helper used by both the app and CLI scripts.
/// Uses AES-CBC with a fixed IV for deterministic encryption.
/// Must be initialized once before use via [init()].
class DeterministicEncryptionHelper {
  static late final encrypt.Key _key;
  static late final encrypt.IV _fixedIV;

  /// Loads encryption key/IV from `.env` at project root.
  static Future<void> init() async {
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: ".env");
    }

    final key = dotenv.env['ENCRYPTION_KEY'];
    final iv = dotenv.env['ENCRYPTION_IV'];

    if (key == null || iv == null) {
      throw Exception(
        "Missing ENCRYPTION_KEY or ENCRYPTION_IV in .env file.\n"
            "Please define them before using encryption.",
      );
    }

    // ✅ Integrity check — right here
    if (key.length != 32 || iv.length != 16) {
      throw Exception(
        'Invalid key/IV length: key must be 32 chars, iv must be 16 chars.',
      );
    }

    _key = encrypt.Key.fromUtf8(key);
    _fixedIV = encrypt.IV.fromUtf8(iv);
  }


  static String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter =
    encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    return base64Encode(encrypted.bytes);
  }

  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      final encrypter =
      encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(bytes)),
        iv: _fixedIV,
      );
      return decrypted;
    } catch (_) {
      return '[DECRYPTION_FAILED]';
    }
  }

  static String hashPassword(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  // inside DeterministicEncryptionHelper
  static void configureLogger({
    void Function(String message)? info,
    void Function(String message, Object? error, StackTrace? stack)? error,
  }) {
    _infoLog = info;
    _errorLog = error;
  }

  static void Function(String message)? _infoLog;
  static void Function(String message, Object? error, StackTrace? stack)? _errorLog;

  static void _logInfo(String message) => _infoLog?.call(message);
  static void _logError(String message, Object e, StackTrace s) =>
      _errorLog?.call(message, e, s);
}
