import 'package:segundo_cogni/features/evaluator/domain/evaluator_registration_data.dart';
import '../../../core/utils/encryption_helper.dart';
import '../domain/evaluator_entity.dart';
import 'evaluator_constants.dart';

class EvaluatorModel extends EvaluatorEntity {
  const EvaluatorModel({
    super.evaluatorId,
    required super.name,
    required super.surname,
    required super.email,
    required super.birthDate,
    required super.specialty,
    required super.cpfOrNif,
    required super.username,
    required super.password,
    super.firstLogin = true,
  });

  factory EvaluatorModel.fromMap(Map<String, dynamic> map) =>
      EvaluatorModel(
        evaluatorId: map[EvaluatorFields.id] as int?,
        name: map[EvaluatorFields.name],
        surname: map[EvaluatorFields.surname],
        email: map[EvaluatorFields.email],
        birthDate: map[EvaluatorFields.birthDate],
        specialty: map[EvaluatorFields.specialty],
        cpfOrNif: map[EvaluatorFields.cpf],
        username: map[EvaluatorFields.username],
        password: map[EvaluatorFields.password],
        firstLogin: (map[EvaluatorFields.firstLogin] as int) == 1,
      );

  Map<String, dynamic> toMap() =>
      {
        EvaluatorFields.id: evaluatorId,
        EvaluatorFields.name: name,
        EvaluatorFields.surname: surname,
        EvaluatorFields.email: email,
        EvaluatorFields.birthDate: birthDate,
        EvaluatorFields.specialty: specialty,
        EvaluatorFields.cpf: cpfOrNif,
        EvaluatorFields.username: username,
        EvaluatorFields.password: password,
        EvaluatorFields.firstLogin: firstLogin ? 1 : 0,
      };

  Map<String, dynamic> toJson() =>
      {
        'evaluator_id': evaluatorId,
        'name': name,
        'surname': surname,
        'email': email,
        'birthDate': birthDate,
        'specialty': specialty,
        'cpfOrNif': cpfOrNif,
        'username': username,
        'password': password,
        'firstLogin': firstLogin,
      };

  factory EvaluatorModel.fromEntity(EvaluatorEntity entity) =>
      EvaluatorModel(
        evaluatorId: entity.evaluatorId,
        name: entity.name,
        surname: entity.surname,
        email: entity.email,
        birthDate: entity.birthDate,
        specialty: entity.specialty,
        cpfOrNif: entity.cpfOrNif,
        username: entity.username,
        password: entity.password,
        firstLogin: entity.firstLogin,
      );

  factory EvaluatorModel.fromDTO(EvaluatorRegistrationData dto) {
    return EvaluatorModel(
      name: dto.name,
      surname: dto.surname,
      email: dto.email,
      birthDate: dto.birthDate,
      specialty: dto.specialty,
      cpfOrNif: dto.cpf,
      username: dto.username,
      password: dto.password,
      firstLogin: dto.firstLogin,
    );
  }

  EvaluatorModel encrypted() {
    return EvaluatorModel(
      evaluatorId: evaluatorId,
      name: EncryptionHelper.encryptText(name),
      surname: EncryptionHelper.encryptText(surname),
      email: EncryptionHelper.encryptText(email),
      birthDate: EncryptionHelper.encryptText(birthDate),
      specialty: EncryptionHelper.encryptText(specialty),
      cpfOrNif: EncryptionHelper.encryptText(cpfOrNif),
      username: EncryptionHelper.encryptText(username),
      password: password,
      // already hashed
      firstLogin: firstLogin,
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
      password: model.password,
    );
  }


  EvaluatorModel copyWith({
    int? evaluatorId,
    String? name,
    String? surname,
    String? email,
    String? birthDate,
    String? specialty,
    String? cpfOrNif,
    String? username,
    String? password,
    bool? firstLogin,
  }) {
    return EvaluatorModel(
      evaluatorId: evaluatorId ?? this.evaluatorId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      specialty: specialty ?? this.specialty,
      cpfOrNif: cpfOrNif ?? this.cpfOrNif,
      username: username ?? this.username,
      password: password ?? this.password,
      firstLogin: firstLogin ?? this.firstLogin,
    );
  }

}