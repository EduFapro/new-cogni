import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../core/logger/app_logger.dart'; // <-- import your AppLogger

class DeterministicEncryptionHelper {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _fixedIV = encrypt.IV.fromUtf8('myfixediv1234567');

  static String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    final encoded = base64Encode(encrypted.bytes);
    AppLogger.info('[Encrypt] 🔓 PlainText: $plainText → 🔐 Encrypted base64: $encoded');
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
      AppLogger.info('[Decrypt] 🔐 Encrypted base64: $encryptedText → 🔓 Decrypted: $decrypted');
      return decrypted;
    } catch (e, s) {
      AppLogger.error('[Decrypt] 💥 Error decrypting base64: $encryptedText', e, s);
      return '[DECRYPTION_FAILED]';
    }
  }
}
