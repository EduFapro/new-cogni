import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

import '../../core/logger/app_logger.dart';
import 'deterministic_encryption_helper.dart';

/// Helper for encrypting and decrypting audio recording files.
/// Uses AES encryption with a random IV per file.
/// The IV is stored in a separate .iv file alongside the encrypted file.
class FileEncryptionHelper {
  /// Encrypts a file and returns the path to the encrypted file.
  ///
  /// The encrypted file will have a .enc extension.
  /// The IV will be stored in a separate .iv file.
  ///
  /// Example:
  /// - Input: /path/to/recording.aac
  /// - Output: /path/to/recording.aac.enc
  /// - IV file: /path/to/recording.aac.enc.iv
  ///
  /// Returns the path to the .enc file.
  static Future<String> encryptFile(String sourcePath) async {
    try {
      AppLogger.info('🔐 Encrypting file: $sourcePath');

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourcePath');
      }

      // Read the file bytes
      final bytes = await sourceFile.readAsBytes();
      AppLogger.info('📊 File size: ${bytes.length} bytes');

      // Generate a random IV for this file
      final iv = encrypt.IV.fromLength(16);
      AppLogger.info('🔑 Generated random IV');

      // Get the encryption key from DeterministicEncryptionHelper
      // (we reuse the same key setup but with random IVs for files)
      await DeterministicEncryptionHelper.init();
      final key = DeterministicEncryptionHelper.key;

      // Encrypt the bytes
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);

      // Write encrypted file
      final encryptedPath = '$sourcePath.enc';
      final encryptedFile = File(encryptedPath);
      await encryptedFile.writeAsBytes(encrypted.bytes);
      AppLogger.info('✅ Encrypted file saved: $encryptedPath');

      // Write IV file
      final ivPath = '$encryptedPath.iv';
      final ivFile = File(ivPath);
      await ivFile.writeAsBytes(iv.bytes);
      AppLogger.info('✅ IV file saved: $ivPath');

      return encryptedPath;
    } catch (e, s) {
      AppLogger.error('❌ Failed to encrypt file: $sourcePath', e, s);
      rethrow;
    }
  }

  /// Decrypts a file to the specified destination path.
  ///
  /// Example:
  /// - Input encrypted: /path/to/recording.aac.enc
  /// - Input IV: /path/to/recording.aac.enc.iv (automatically located)
  /// - Output: /path/to/decrypted.aac
  static Future<void> decryptFile(
    String encryptedPath,
    String destinationPath,
  ) async {
    try {
      AppLogger.info('🔓 Decrypting file: $encryptedPath');

      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw Exception('Encrypted file does not exist: $encryptedPath');
      }

      // Read IV
      final ivPath = '$encryptedPath.iv';
      final ivFile = File(ivPath);
      if (!await ivFile.exists()) {
        throw Exception('IV file does not exist: $ivPath');
      }
      final ivBytes = await ivFile.readAsBytes();
      final iv = encrypt.IV(ivBytes);
      AppLogger.info('🔑 Loaded IV from file');

      // Read encrypted bytes
      final encryptedBytes = await encryptedFile.readAsBytes();
      AppLogger.info('📊 Encrypted file size: ${encryptedBytes.length} bytes');

      // Get the encryption key
      await DeterministicEncryptionHelper.init();
      final key = DeterministicEncryptionHelper.key;

      // Decrypt
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedBytes),
        iv: iv,
      );

      // Write decrypted file
      final destinationFile = File(destinationPath);
      await destinationFile.writeAsBytes(decrypted);
      AppLogger.info('✅ Decrypted file saved: $destinationPath');
    } catch (e, s) {
      AppLogger.error('❌ Failed to decrypt file: $encryptedPath', e, s);
      rethrow;
    }
  }

  /// Decrypts a file to memory for immediate playback.
  /// Returns the decrypted bytes.
  static Future<Uint8List> decryptFileToMemory(String encryptedPath) async {
    try {
      AppLogger.info('🔓 Decrypting file to memory: $encryptedPath');

      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw Exception('Encrypted file does not exist: $encryptedPath');
      }

      // Read IV
      final ivPath = '$encryptedPath.iv';
      final ivFile = File(ivPath);
      if (!await ivFile.exists()) {
        throw Exception('IV file does not exist: $ivPath');
      }
      final ivBytes = await ivFile.readAsBytes();
      final iv = encrypt.IV(ivBytes);

      // Read encrypted bytes
      final encryptedBytes = await encryptedFile.readAsBytes();

      // Get the encryption key
      await DeterministicEncryptionHelper.init();
      final key = DeterministicEncryptionHelper.key;

      // Decrypt
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedBytes),
        iv: iv,
      );

      AppLogger.info('✅ File decrypted to memory: ${decrypted.length} bytes');
      return Uint8List.fromList(decrypted);
    } catch (e, s) {
      AppLogger.error(
        '❌ Failed to decrypt file to memory: $encryptedPath',
        e,
        s,
      );
      rethrow;
    }
  }

  /// Deletes the original unencrypted file after encryption.
  /// Should be called after successful encryption.
  static Future<void> deleteOriginalFile(String originalPath) async {
    try {
      final file = File(originalPath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('🗑️ Deleted original file: $originalPath');
      }
    } catch (e, s) {
      AppLogger.error('❌ Failed to delete original file: $originalPath', e, s);
      // Don't rethrow - this is not critical
    }
  }
}
