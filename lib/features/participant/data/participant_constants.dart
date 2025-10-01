import '../../../core/constants/database_constants.dart';

class ParticipantFields {
  static const id = "participant_id";
  static const name = "name";
  static const surname = "surname";
  static const educationLevel = "education";
  static const sex = "sex";
  static const birthDate = "birth_date";

  static const all = [
    id,
    name,
    surname,
    educationLevel,
    sex,
    birthDate,
  ];
}

const scriptCreateTableParticipants = '''
CREATE TABLE ${Tables.participants} (
  ${ParticipantFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ParticipantFields.name} TEXT NOT NULL,
  ${ParticipantFields.surname} TEXT NOT NULL,
  ${ParticipantFields.educationLevel} INT CHECK(${ParticipantFields.educationLevel} BETWEEN 1 AND 7),
  ${ParticipantFields.sex} INT CHECK(${ParticipantFields.sex} IN (1, 2)),
  ${ParticipantFields.birthDate} TIMESTAMP
);
''';
