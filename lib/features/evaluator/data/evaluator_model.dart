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
    // Align with DB default (0 → false)
    super.firstLogin = false,
    super.token,
    super.creationDate,
  });

  factory EvaluatorModel.fromMap(Map<String, dynamic> map) => EvaluatorModel(
    evaluatorId: map[EvaluatorFields.id] as int?,
    name: map[EvaluatorFields.name] as String,
    surname: map[EvaluatorFields.surname] as String,
    email: map[EvaluatorFields.email] as String,
    birthDate: map[EvaluatorFields.birthDate] as String,
    specialty: map[EvaluatorFields.specialty] as String,
    cpfOrNif: map[EvaluatorFields.cpf] as String,
    username: map[EvaluatorFields.username] as String,
    password: map[EvaluatorFields.password] as String,
    firstLogin: (map[EvaluatorFields.firstLogin] as int) == 1,
    token: map['token'] as String?,
    creationDate: map['creationDate'] as String?,
  );

  factory EvaluatorModel.fromJson(Map<String, dynamic> json) => EvaluatorModel(
    evaluatorId: json['id'] as int?,
    name: json['name'] as String,
    surname: json['surname'] as String,
    email: json['email'] as String,
    birthDate: json['birthDate'] as String,
    specialty: json['specialty'] as String,
    cpfOrNif: json['cpfOrNif'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    firstLogin: json['firstLogin'] as bool? ?? false,
    token: json['token'] as String?,
    creationDate: json['creationDate'] as String?,
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
    'token': token,
    'creationDate': creationDate,
  };

  Map<String, dynamic> toEvaluatorTableMap() => {
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
    'creationDate': creationDate,
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
    'token': token,
    'creationDate': creationDate,
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
    token: entity.token,
    creationDate: entity.creationDate,
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
    String? token,
    String? creationDate,
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
      token: token ?? this.token,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}
