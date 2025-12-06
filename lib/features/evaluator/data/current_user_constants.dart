import '../../../core/constants/database_constants.dart';
import 'evaluator_constants.dart';

class CurrentUserFields {
  static const id = EvaluatorFields.id;
  static const name = EvaluatorFields.name;
  static const surname = EvaluatorFields.surname;
  static const email = EvaluatorFields.email;
  static const birthDate = EvaluatorFields.birthDate;
  static const specialty = EvaluatorFields.specialty;
  static const cpf = EvaluatorFields.cpf;
  static const username = EvaluatorFields.username;
  static const password = EvaluatorFields.password;
  static const firstLogin = EvaluatorFields.firstLogin;
  static const isAdmin = EvaluatorFields.isAdmin;
  static const token = 'token';

  static const values = [
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
    token,
  ];
}

const scriptCreateTableCurrentUser =
    '''
CREATE TABLE ${Tables.currentUser} (
  ${CurrentUserFields.id} INTEGER PRIMARY KEY,
  ${CurrentUserFields.name} TEXT NOT NULL,
  ${CurrentUserFields.surname} TEXT NOT NULL,
  ${CurrentUserFields.email} TEXT NOT NULL,
  ${CurrentUserFields.birthDate} TIMESTAMP,
  ${CurrentUserFields.specialty} TEXT,
  ${CurrentUserFields.cpf} TEXT,
  ${CurrentUserFields.username} TEXT NOT NULL UNIQUE,
  ${CurrentUserFields.password} TEXT NOT NULL,
  ${CurrentUserFields.isAdmin} INTEGER NOT NULL DEFAULT 0,
  ${CurrentUserFields.firstLogin} INTEGER NOT NULL DEFAULT 0,
  ${CurrentUserFields.token} TEXT,
  FOREIGN KEY (${CurrentUserFields.id})
    REFERENCES ${Tables.evaluators}(${EvaluatorFields.id})
    ON DELETE CASCADE ON UPDATE CASCADE
);
''';
