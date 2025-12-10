import '../../../core/constants/enums/laterality_enums.dart';
import '../../../core/constants/enums/person_enums.dart';

import '../data/participant_constants.dart';

class ParticipantEntity {
  final int? participantID;
  final String name;
  final String surname;
  final DateTime birthDate;
  final Sex sex;
  final EducationLevel educationLevel;
  final Laterality laterality;

  ParticipantEntity({
    this.participantID,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.sex,
    required this.educationLevel,
    required this.laterality,
  });

  static ParticipantEntity fromMap(Map<String, dynamic> map) {
    return ParticipantEntity(
      participantID: map[ParticipantFields.id],
      name: map[ParticipantFields.name],
      surname: map[ParticipantFields.surname],
      birthDate: DateTime.parse(map[ParticipantFields.birthDate]),
      sex: Sex.fromValue(map[ParticipantFields.sex]),
      educationLevel: EducationLevel.fromValue(
        map[ParticipantFields.educationLevel],
      ),
      laterality: Laterality.fromValue(map[ParticipantFields.laterality]),
    );
  }

  Map<String, dynamic> toMap() => {
    ParticipantFields.id: participantID,
    ParticipantFields.name: name,
    ParticipantFields.surname: surname,
    ParticipantFields.birthDate: birthDate.toIso8601String(),
    ParticipantFields.sex: sex.numericValue,
    ParticipantFields.educationLevel: educationLevel.numericValue,
    ParticipantFields.laterality: laterality.numericValue,
  };

  // For sending to backend API (unencrypted - backend stores plain text)
  Map<String, dynamic> toJsonForApi({
    int? evaluatorId,
    List<int>? selectedModuleIds,
    String? avatar,
  }) => {
    if (participantID != null) 'id': participantID,
    'name': name, // Plain text (not encrypted)
    'surname': surname, // Plain text (not encrypted)
    'birthDate': birthDate.toIso8601String().split('T')[0], // yyyy-MM-dd format
    'sex': sex.numericValue,
    'educationLevel': educationLevel.numericValue,
    'laterality': laterality.numericValue,
    if (evaluatorId != null) 'evaluatorId': evaluatorId,
    if (selectedModuleIds != null) 'selectedModuleIds': selectedModuleIds,
    if (avatar != null) 'avatar': avatar,
  };

  // For receiving from backend API
  factory ParticipantEntity.fromJson(Map<String, dynamic> json) {
    return ParticipantEntity(
      participantID: json['id'] as int?,
      name: json['name'] as String,
      surname: json['surname'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      sex: Sex.fromValue(json['sex'] as int),
      educationLevel: EducationLevel.fromValue(json['educationLevel'] as int),
      laterality: Laterality.fromValue(json['laterality'] as int),
    );
  }

  ParticipantEntity copyWith({
    int? participantID,
    String? name,
    String? surname,
    DateTime? birthDate,
    Sex? sex,
    EducationLevel? educationLevel,
    Laterality? laterality,
  }) {
    return ParticipantEntity(
      participantID: participantID ?? this.participantID,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      educationLevel: educationLevel ?? this.educationLevel,
      laterality: laterality ?? this.laterality,
    );
  }

  @override
  String toString() =>
      'ParticipantEntity(id: $participantID, name: $name, surname: $surname, sex: $sex, education: $educationLevel)';

  String get fullName => '$name $surname';
}
