import '../../../shared/encryption/deterministic_encryption_helper.dart';
import '../application/evaluator_secure_service.dart';
import 'evaluator_model.dart';

extension EvaluatorModelDecryption on EvaluatorModel {
  EvaluatorModel decrypted() {
    return EvaluatorModel(
      evaluatorId: evaluatorId,
      name: DeterministicEncryptionHelper.decryptText(name),
      surname: DeterministicEncryptionHelper.decryptText(surname),
      email: DeterministicEncryptionHelper.decryptText(email),
      birthDate: DeterministicEncryptionHelper.decryptText(birthDate),
      specialty: DeterministicEncryptionHelper.decryptText(specialty),
      cpfOrNif: DeterministicEncryptionHelper.decryptText(cpfOrNif),
      username: DeterministicEncryptionHelper.decryptText(username),
      password: password,
      firstLogin: firstLogin,
    );
  }
}
