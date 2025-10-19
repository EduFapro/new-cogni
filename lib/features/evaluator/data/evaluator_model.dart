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
    super.isAdmin = false,
  });

  factory EvaluatorModel.fromMap(Map<String, dynamic> map) => EvaluatorModel(
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
    isAdmin: (map[EvaluatorFields.isAdmin] as int) == 1,
  );

  Map<String, dynamic> toMap() => {
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
    EvaluatorFields.isAdmin: isAdmin ? 1 : 0,
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
