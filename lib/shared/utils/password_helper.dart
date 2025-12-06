import 'package:bcrypt/bcrypt.dart';

class PasswordHelper {
  /// Hashes a password using BCrypt.
  static String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifies a password against a BCrypt hash.
  static bool verify(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}
