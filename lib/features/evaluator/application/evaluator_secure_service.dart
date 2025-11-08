import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/utils/encryption_helper.dart';
import '../data/evaluator_model.dart';

/// Encryption and hashing only — no validation
class EvaluatorSecureService {
  static EvaluatorModel encrypt(EvaluatorModel model) {
    return model.copyWith(
      name: EncryptionHelper.encryptText(model.name),
      surname: EncryptionHelper.encryptText(model.surname),
      email: EncryptionHelper.encryptText(model.email),
      birthDate: EncryptionHelper.encryptText(model.birthDate),
      specialty: EncryptionHelper.encryptText(model.specialty),
      cpfOrNif: EncryptionHelper.encryptText(model.cpfOrNif),
      username: EncryptionHelper.encryptText(model.username),
      password: _hash(model.password),
    );
  }

  static EvaluatorModel decrypt(EvaluatorModel model) {
    return model.copyWith(
      name: EncryptionHelper.decryptText(model.name),
      surname: EncryptionHelper.decryptText(model.surname),
      email: EncryptionHelper.decryptText(model.email),
      birthDate: EncryptionHelper.decryptText(model.birthDate),
      specialty: EncryptionHelper.decryptText(model.specialty),
      cpfOrNif: EncryptionHelper.decryptText(model.cpfOrNif),
      username: EncryptionHelper.decryptText(model.username),
    );
  }

  static String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
