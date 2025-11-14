import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/deterministic_encryption_helper.dart';
import '../data/evaluator_model.dart';

class EvaluatorSecureService {
  static EvaluatorModel encrypt(EvaluatorModel model) {
    return model.copyWith(
      name: DeterministicEncryptionHelper.encryptText(model.name),
      surname: DeterministicEncryptionHelper.encryptText(model.surname),
      email: DeterministicEncryptionHelper.encryptText(model.email),
      birthDate: DeterministicEncryptionHelper.encryptText(model.birthDate),
      specialty: DeterministicEncryptionHelper.encryptText(model.specialty),
      cpfOrNif: DeterministicEncryptionHelper.encryptText(model.cpfOrNif),
      username: DeterministicEncryptionHelper.encryptText(model.username),
      password: hash(model.password), // password stays hashed
    );
  }

  static EvaluatorModel decrypt(EvaluatorModel model) {
    return model.copyWith(
      name: DeterministicEncryptionHelper.decryptText(model.name),
      surname: DeterministicEncryptionHelper.decryptText(model.surname),
      email: DeterministicEncryptionHelper.decryptText(model.email),
      birthDate: DeterministicEncryptionHelper.decryptText(model.birthDate),
      specialty: DeterministicEncryptionHelper.decryptText(model.specialty),
      cpfOrNif: DeterministicEncryptionHelper.decryptText(model.cpfOrNif),
      username: DeterministicEncryptionHelper.decryptText(model.username),
      // password remains hashed
    );
  }

  static String hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
