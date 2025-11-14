import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class DeterministicEncryptionHelper {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _fixedIV = encrypt.IV.fromUtf8('myfixediv1234567');

  static String encryptText(String plainText) {
    print('[Encrypt] 🔓 PlainText: $plainText');
    if (plainText.isEmpty) return '';
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _fixedIV);
    final encoded = base64Encode(encrypted.bytes);
    print('[Encrypt] 🔐 Encrypted base64: $encoded');
    return encoded;
  }

  static String decryptText(String encryptedText) {
    print('[Decrypt] 🔐 Encrypted base64: $encryptedText');
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64Decode(encryptedText);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(bytes)),
        iv: _fixedIV,
      );
      print('[Decrypt] 🔓 Decrypted: $decrypted');
      return decrypted;
    } catch (e) {
      print('[Decrypt] 💥 Error during decryption: $e');
      return '[DECRYPTION_FAILED]';
    }
  }
}
