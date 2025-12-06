import '../../../shared/utils/password_helper.dart';
import '../data/evaluator_model.dart';

class EvaluatorSecureService {
  static Future<EvaluatorModel> encrypt(EvaluatorModel model) async {
    // Encryption removed for all fields except password (which is hashed).
    // Data is now stored as plain text in the local DB.
    return model.copyWith(
      name: model.name,
      surname: model.surname,
      email: model.email,
      birthDate: model.birthDate,
      specialty: model.specialty,
      cpfOrNif: model.cpfOrNif,
      username: model.username,
      password: hash(model.password), // password stays hashed
    );
  }

  static Future<EvaluatorModel> decrypt(EvaluatorModel model) async {
    // No decryption needed as fields are plain text.
    return model;
  }

  static String hash(String input) {
    // Use BCrypt for password hashing
    return PasswordHelper.hash(input);
  }
}
