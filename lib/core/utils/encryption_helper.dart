// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:encrypt/encrypt.dart' as encrypt;
//
// class EncryptionHelper {
//   static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
//
//   static String encryptText(String plainText) {
//     if (plainText.isEmpty) return '';
//     final iv = encrypt.IV.fromSecureRandom(16);
//     final encrypter = encrypt.Encrypter(encrypt.AES(_key));
//     final encrypted = encrypter.encrypt(plainText, iv: iv);
//     final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
//     return base64Encode(combined);
//   }
//
//   static String decryptText(String encryptedText) {
//     if (encryptedText.isEmpty) return '';
//     try {
//       final raw = base64Decode(encryptedText);
//       final iv = encrypt.IV(Uint8List.fromList(raw.sublist(0, 16)));
//       final ciphertext = raw.sublist(16);
//       final encrypter = encrypt.Encrypter(encrypt.AES(_key));
//       return encrypter.decrypt(
//         encrypt.Encrypted(Uint8List.fromList(ciphertext)),
//         iv: iv,
//       );
//     } catch (e) {
//       return '[DECRYPTION_FAILED]';
//     }
//   }
// }
