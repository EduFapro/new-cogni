// import '../../../core/deterministic_encryption_helper.dart';
// import '../application/evaluator_secure_service.dart';
// import 'evaluator_model.dart';
//
// /// Encrypt PII and hash password
// extension EvaluatorModelSecurity on EvaluatorModel {
//   EvaluatorModel encryptedAndHashed() {
//     return EvaluatorModel(
//       evaluatorId: evaluatorId,
//       name: DeterministicEncryptionHelper.encryptText(name),
//       surname: DeterministicEncryptionHelper.encryptText(surname),
//       email: DeterministicEncryptionHelper.encryptText(email),
//       birthDate: DeterministicEncryptionHelper.encryptText(birthDate),
//       specialty: DeterministicEncryptionHelper.encryptText(specialty),
//       cpfOrNif: DeterministicEncryptionHelper.encryptText(cpfOrNif),
//       username: DeterministicEncryptionHelper.encryptText(username),
//       password: EvaluatorSecureService.hash(password),
//       firstLogin: firstLogin,
//     );
//   }
// }
//
// extension EvaluatorModelDecryption on EvaluatorModel {
//   EvaluatorModel decrypted() {
//     return EvaluatorModel(
//       evaluatorId: evaluatorId,
//       name: DeterministicEncryptionHelper.decryptText(name),
//       surname: DeterministicEncryptionHelper.decryptText(surname),
//       email: DeterministicEncryptionHelper.decryptText(email),
//       birthDate: DeterministicEncryptionHelper.decryptText(birthDate),
//       specialty: DeterministicEncryptionHelper.decryptText(specialty),
//       cpfOrNif: DeterministicEncryptionHelper.decryptText(cpfOrNif),
//       username: DeterministicEncryptionHelper.decryptText(username),
//       password: password,
//       firstLogin: firstLogin,
//     );
//   }
// }
