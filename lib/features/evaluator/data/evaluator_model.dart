import 'package:segundo_cogni/features/evaluator/domain/evaluator_registration_data.dart';

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
    super.isAdmin = true,
  });


  factory EvaluatorModel.fromMap(Map<String, dynamic> map) => EvaluatorModel(
    evaluatorId: map[ID_EVALUATOR] as int?,
    name: map[EVALUATOR_NAME],
    surname: map[EVALUATOR_SURNAME],
    email: map[EMAIL],
    birthDate: map[BIRTH_DATE_EVALUATOR],
    specialty: map[SPECIALTY_EVALUATOR],
    cpfOrNif: map[CPF_EVALUATOR],
    username: map[USERNAME_EVALUATOR],
    password: map[PASSWORD_EVALUATOR],
    firstLogin: (map[FIRST_LOGIN] as int) == 1,
    isAdmin: (map[IS_ADMIN] as int) == 1,
  );


  Map<String, dynamic> toMap() => {
    ID_EVALUATOR: evaluatorId,
    EVALUATOR_NAME: name,
    EVALUATOR_SURNAME: surname,
    EMAIL: email,
    BIRTH_DATE_EVALUATOR: birthDate,
    SPECIALTY_EVALUATOR: specialty,
    CPF_EVALUATOR: cpfOrNif,
    USERNAME_EVALUATOR: username,
    PASSWORD_EVALUATOR: password,
    FIRST_LOGIN: firstLogin ? 1 : 0,
    IS_ADMIN: isAdmin ? 1 : 0,
  };


  Map<String, dynamic> toJson() => {
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
    'isAdmin': isAdmin,
  };

  factory EvaluatorModel.fromEntity(EvaluatorEntity entity) => EvaluatorModel(
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
    isAdmin: entity.isAdmin,
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
      isAdmin: dto.isAdmin,
      firstLogin: dto.firstLogin,
    );
  }
}
