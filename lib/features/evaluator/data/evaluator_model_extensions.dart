import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:segundo_cogni/core/utils/encryption_helper.dart';
import 'evaluator_model.dart';

extension EvaluatorModelSecurity on EvaluatorModel {
  EvaluatorModel encryptedAndHashed() {
    return EvaluatorModel(
      evaluatorId: evaluatorId,
      name: EncryptionHelper.encryptText(name),
      surname: EncryptionHelper.encryptText(surname),
      email: EncryptionHelper.encryptText(email),
      birthDate: EncryptionHelper.encryptText(birthDate),
      specialty: EncryptionHelper.encryptText(specialty),
      cpfOrNif: EncryptionHelper.encryptText(cpfOrNif),
      username: EncryptionHelper.encryptText(username),
      password: _hash(password),
      firstLogin: firstLogin,
    );
  }

  static String _hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}

extension EvaluatorModelDecryption on EvaluatorModel {
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
      password: password, // leave hashed
      firstLogin: firstLogin,
    );
  }
}
