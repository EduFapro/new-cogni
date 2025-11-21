// lib/shared/encryption/deterministic_encryption_helper.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform, File, Directory;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Shared deterministic AES helper used by both Flutter app and CLI scripts.
/// - Flutter debug mode → logs via AppLogger
/// - CLI mode → logs with print()
/// - Production → silent
class DeterministicEncryptionHelper {
  static late final encrypt.Key _key;
  static late final encrypt.IV _fixedIV;

  static void Function(String message)? _infoLog;
  static void Function(String message, Object? error, StackTrace? stack)? _errorLog;

  /// Connects a Flutter logger (e.g., AppLogger)
  static void configureLogger({
    void Function(String message)? info,
    void Function(String message, Object? error, StackTrace? stack)? error,
  }) {
    _infoLog = info;
    _errorLog = error;
  }

  /// Loads encryption key/IV from `.env` and validates them.
  static Future<void> init() async {
    _logInfo('🧩 Initializing encryption helper...');
    final searchPaths = [
      '.env', // typical Flutter run path (project root)
      'lib/.env', // fallback if dev accidentally placed inside lib
      '../.env', // fallback when running from build/windows/runner
      '../../.env', // deeper fallback for nested executables
    ];

    String? foundPath;

    for (final path in searchPaths) {
      final file = File(path);
      _logInfo('🔍 Checking for .env at: ${file.absolute.path}');
      if (file.existsSync()) {
        foundPath = path;
        _logInfo('✅ Found .env at: ${file.absolute.path}');
        await dotenv.load(fileName: path);
        break;
      }
    }

    if (foundPath == null) {
      _logError(
        '❌ Could not find .env in any known paths!',
        Exception('Missing .env file'),
        StackTrace.current,
      );
      throw Exception(
        "Missing .env file. Checked paths:\n${searchPaths.join('\n')}",
      );
    }

    final key = dotenv.env['ENCRYPTION_KEY'];
    final iv = dotenv.env['ENCRYPTION_IV'];
    final env = dotenv.env['ENV'] ?? 'development';

    if (key == null || iv == null) {
      throw Exception(
        "Missing ENCRYPTION_KEY or ENCRYPTION_IV in .env file.\n"
            "Please define them before using encryption.",
      );
    }

    if (key.length != 32 || iv.length != 16) {
      throw Exception(
        'Invalid key/IV length: key must be 32 chars, iv must be 16 chars.',
      );
    }

    _key = encrypt.Key.fromUtf8(key);
    _fixedIV = encrypt.IV.fromUtf8(iv);

    _logInfo('🔑 Encryption helper initialized successfully (ENV=$env)');
  }


  static String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    final base64Text = base64Encode(encrypted.bytes);
    _logInfo('[Encrypt] "$plainText" → $base64Text');
    return base64Text;
  }

  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(bytes)),
        iv: _fixedIV,
      );
      _logInfo('[Decrypt] $encryptedText → "$decrypted"');
      return decrypted;
    } catch (e, s) {
      _logError('[Decrypt] 💥 Failed to decrypt: $encryptedText', e, s);
      return '[DECRYPTION_FAILED]';
    }
  }

  static String hashPassword(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  // -------- Internal Logging --------
  static void _logInfo(String message) {
    if (!_shouldLog) return;
    if (_infoLog != null) {
      _infoLog!(message);
    } else {
      print('[EncryptionHelper] $message');
    }
  }

  static void _logError(String message, Object e, StackTrace s) {
    if (!_shouldLog) return;
    if (_errorLog != null) {
      _errorLog!(message, e, s);
    } else {
      print('[EncryptionHelper][ERROR] $message\nError: $e\n$s');
    }
  }

  static bool get _shouldLog {
    // Fallback safely if dotenv not yet loaded
    String env;
    try {
      env = dotenv.isInitialized ? (dotenv.env['ENV'] ?? 'development') : 'development';
    } catch (_) {
      env = 'development';
    }

    final isFlutter = Platform.environment.containsKey('FLUTTER_ROOT');
    final isProd = env.toLowerCase() == 'production';
    return !isProd && (kDebugMode || !isFlutter);
  }

}
