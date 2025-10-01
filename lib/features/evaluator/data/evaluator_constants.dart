import '../../../core/constants/database_constants.dart';

class EvaluatorFields {
  static const id = "evaluator_id";
  static const name = "name";
  static const surname = "surname";
  static const email = "email";
  static const birthDate = "birth_date";
  static const specialty = "specialty";
  static const cpf = "cpf";
  static const username = "username";
  static const password = "password";
  static const firstLogin = "first_login";
  static const isAdmin = "is_admin";

  static const all = [
    id,
    name,
    surname,
    email,
    birthDate,
    specialty,
    cpf,
    username,
    password,
    firstLogin,
    isAdmin,
  ];
}

const scriptCreateTableEvaluators = '''
CREATE TABLE ${Tables.evaluators} (
  ${EvaluatorFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${EvaluatorFields.name} TEXT NOT NULL,
  ${EvaluatorFields.surname} TEXT NOT NULL,
  ${EvaluatorFields.email} TEXT NOT NULL,
  ${EvaluatorFields.birthDate} TIMESTAMP,
  ${EvaluatorFields.specialty} TEXT,
  ${EvaluatorFields.cpf} TEXT,
  ${EvaluatorFields.username} TEXT NOT NULL UNIQUE,
  ${EvaluatorFields.password} TEXT NOT NULL DEFAULT '0000',
  ${EvaluatorFields.firstLogin} INTEGER NOT NULL DEFAULT 0,
  ${EvaluatorFields.isAdmin} INTEGER NOT NULL DEFAULT 0
);
''';
