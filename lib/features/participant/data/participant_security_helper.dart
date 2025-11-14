import 'dart:convert';
import 'package:crypto/crypto.dart';

class ParticipantSecurityHelper {
  /// Hash a string using SHA-256
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Optionally: hash + truncate to first 10 characters for display anonymization
  static String shortHash(String input) {
    return hashSha256(input).substring(0, 10);
  }
}
