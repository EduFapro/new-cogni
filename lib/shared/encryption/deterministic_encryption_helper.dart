import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class DeterministicEncryptionHelper {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _fixedIV = encrypt.IV.fromUtf8('myfixediv1234567');

  // ---- Logger hooks (set by Flutter app or CLI seed) ----
  static void Function(String message)? _logInfo;
  static void Function(String message, [Object? error, StackTrace? stack])?
  _logError;

  static void configureLogger({
    void Function(String message)? info,
    void Function(String message, [Object? error, StackTrace? stack])? error,
  }) {
    _logInfo = info;
    _logError = error;
  }

  static void _info(String msg) {
    _logInfo?.call(msg);
  }

  static void _error(String msg, [Object? e, StackTrace? st]) {
    _logError?.call(msg, e, st);
  }

  // ---- Encryption / Decryption ----

  static String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    final encoded = base64Encode(encrypted.bytes);

    _info('[Encrypt] 🔓 $plainText → $encoded');

    return encoded;
  }

  static String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(bytes)),
        iv: _fixedIV,
      );

      _info('[Decrypt] 🔐 $encryptedText → $decrypted');

      return decrypted;
    } catch (e, s) {
      _error('[Decrypt] FAILED for: $encryptedText', e, s);
      return '[DECRYPTION_FAILED]';
    }
  }

  static String hashPassword(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
