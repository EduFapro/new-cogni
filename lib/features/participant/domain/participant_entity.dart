import '../../../core/constants/enums/person_enums.dart';
import '../data/participant_constants.dart';

class ParticipantEntity {
  final int? participantID;
  final String name;
  final String surname;
  final DateTime birthDate;
  final Sex sex;
  final EducationLevel educationLevel;

  ParticipantEntity({
    this.participantID,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.sex,
    required this.educationLevel,
  });

  static ParticipantEntity fromMap(Map<String, dynamic> map) {
    return ParticipantEntity(
      participantID: map[ParticipantFields.id],
      name: map[ParticipantFields.name],
      surname: map[ParticipantFields.surname],
      birthDate: DateTime.parse(map[ParticipantFields.birthDate]),
      sex: Sex.fromValue(map[ParticipantFields.sex]),
      educationLevel: EducationLevel.fromValue(map[ParticipantFields.educationLevel]),
    );
  }

  Map<String, dynamic> toMap() => {
    ParticipantFields.id: participantID,
    ParticipantFields.name: name,
    ParticipantFields.surname: surname,
    ParticipantFields.birthDate: birthDate.toIso8601String(),
    ParticipantFields.sex: sex.numericValue,
    ParticipantFields.educationLevel: educationLevel.numericValue,
  };

  ParticipantEntity copyWith({
    int? participantID,
    String? name,
    String? surname,
    DateTime? birthDate,
    Sex? sex,
    EducationLevel? educationLevel,
  }) {
    return ParticipantEntity(
      participantID: participantID ?? this.participantID,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      educationLevel: educationLevel ?? this.educationLevel,
    );
  }

  @override
  String toString() =>
      'ParticipantEntity(id: $participantID, name: $name, surname: $surname, sex: $sex, education: $educationLevel)';

  String get fullName => '$name $surname';
}
