import '../../../core/utils/encryption_helper.dart';
import '../application/evaluator_secure_service.dart';
import 'evaluator_model.dart';

/// Security helpers for EvaluatorModel kept in a single place to avoid duplicates.
extension EvaluatorModelSecurity on EvaluatorModel {
  /// Encrypt PII and hash the password (canonical version used across the app).
  EvaluatorModel encryptedAndHashed() {
    return EvaluatorModel(
      evaluatorId: evaluatorId,

      // All fields are non-nullable in EvaluatorEntity/EvaluatorModel.
      name: EncryptionHelper.encryptText(name),
      surname: EncryptionHelper.encryptText(surname),
      email: EncryptionHelper.encryptText(email),
      birthDate: EncryptionHelper.encryptText(birthDate),
      specialty: EncryptionHelper.encryptText(specialty),
      cpfOrNif: EncryptionHelper.encryptText(cpfOrNif),
      username: EncryptionHelper.encryptText(username),

      // Hash password (leave as hex string).
      password: EvaluatorSecureService.hash(password),

      // Pass-through flags.
      firstLogin: firstLogin,
    );
  }
}

extension EvaluatorModelDecryption on EvaluatorModel {
  /// Decrypt PII (password remains hashed).
  EvaluatorModel decrypted() {
    return EvaluatorModel(
      evaluatorId: evaluatorId,

      name: EncryptionHelper.decryptText(name),
      surname: EncryptionHelper.decryptText(surname),
      email: EncryptionHelper.decryptText(email),
      birthDate: EncryptionHelper.decryptText(birthDate),
      specialty: EncryptionHelper.decryptText(specialty),
      cpfOrNif: EncryptionHelper.decryptText(cpfOrNif),
      username: EncryptionHelper.decryptText(username),

      // Keep hashed password untouched
      password: password,

      firstLogin: firstLogin,
    );
  }
}
