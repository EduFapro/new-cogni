import 'package:segundo_cogni/core/utils/encryption_helper.dart';
import 'package:segundo_cogni/core/utils/validation_helper.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EvaluatorSecureService {
  static EvaluatorModel processEvaluatorForStorage(EvaluatorModel model) {
    if (!ValidationHelper.isValidEmail(model.email)) {
      throw FormatException('Invalid email format');
    }

    if (!ValidationHelper.isValidPassword(model.password)) {
      throw FormatException('Password must be at least 8 characters long');
    }

    return EvaluatorModel(
      evaluatorId: model.evaluatorId,
      name: EncryptionHelper.encryptText(model.name),
      surname: EncryptionHelper.encryptText(model.surname),
      email: EncryptionHelper.encryptText(model.email),
      birthDate: EncryptionHelper.encryptText(model.birthDate),
      specialty: EncryptionHelper.encryptText(model.specialty),
      cpfOrNif: EncryptionHelper.encryptText(model.cpfOrNif),
      username: EncryptionHelper.encryptText(model.username),
      password: hash(model.password),
      firstLogin: model.firstLogin,
    );
  }

  static String hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
