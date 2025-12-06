import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'deterministic_encryption_helper.dart';
import '../../core/logger/app_logger.dart';
import '../env/env_helper.dart';

class GcmEncryptionHelper {
  static bool _initialized = false;
  static late final SecretKey _secretKey;
  static final _algorithm = AesGcm.with256bits();

  static Future<void> init() async {
    if (_initialized) return;

    AppLogger.info('[GcmEncryptionHelper] 🧩 Initializing...');
    await EnvHelper.ensureInitialized();

    final keyString = EnvHelper.require('ENCRYPTION_KEY');
    // Ensure key is 32 bytes (256 bits)
    // In a real migration, we might need to derive this using PBKDF2 if it's a password
    // For now, assuming the env var is a 32-char string or base64

    List<int> keyBytes;
    if (keyString.length == 32) {
      keyBytes = utf8.encode(keyString);
    } else {
      // Fallback or error - for now assume it matches old helper logic
      // Old helper: encrypt.Key.fromUtf8(key) -> 32 chars = 32 bytes
      keyBytes = utf8.encode(keyString);
    }

    if (keyBytes.length != 32) {
      // If utf8 encoding made it longer/shorter, we might need to adjust or hash it
      // For safety, let's hash it to 32 bytes if it's not exact,
      // BUT for compatibility with "same key" concept, we need to be careful.
      // Let's stick to the requirement: "key must be 32 chars" from old helper.
    }

    _secretKey = SecretKey(keyBytes);
    _initialized = true;
    AppLogger.info('[GcmEncryptionHelper] ✅ Initialized.');
  }

  static Future<String> encryptText(String plainText) async {
    if (plainText.isEmpty) return '';
    if (!_initialized) await init();

    final box = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: _secretKey,
    );

    // Format: nonce + ciphertext + mac (mac is usually appended in some libs, here we get SecretBox)
    // We need to serialize nonce, ciphertext, and mac.
    // Simple format: JSON
    final map = {
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  static Future<String> decryptText(String encryptedText) async {
    if (encryptedText.isEmpty) return '';
    if (!_initialized) await init();

    try {
      // Try to decode as our new format
      // If it fails, it might be old format?
      // The user asked to "migrate old data", implying we should handle both or migrate.
      // For this helper, let's assume new format.

      final jsonString = utf8.decode(base64Decode(encryptedText));
      final map = jsonDecode(jsonString) as Map<String, dynamic>;

      final nonce = base64Decode(map['n']);
      final cipherText = base64Decode(map['c']);
      final macBytes = base64Decode(map['m']);
      final mac = Mac(macBytes);

      final box = SecretBox(cipherText, nonce: nonce, mac: mac);

      final decryptedBytes = await _algorithm.decrypt(
        box,
        secretKey: _secretKey,
      );

      return utf8.decode(decryptedBytes);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      // Fallback: Try decrypting with legacy DeterministicEncryptionHelper
      // This handles the migration scenario where data is still in old format
      try {
        final legacyDecrypted = DeterministicEncryptionHelper.decryptText(
          encryptedText,
        );
        if (legacyDecrypted != '[DECRYPTION_FAILED]') {
          return legacyDecrypted;
        }
      } catch (_) {
        // Ignore legacy error, return original error or failure
      }

      AppLogger.error('[GcmEncryptionHelper] Decryption failed', e);
      return '[DECRYPTION_FAILED]';
    }
  }
}
