import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:segundo_cogni/shared/encryption/deterministic_encryption_helper.dart';
import 'package:segundo_cogni/core/constants/database_constants.dart';
import 'package:segundo_cogni/core/constants/enums/task_mode.dart';
import 'package:segundo_cogni/features/evaluation/data/evaluation_constants.dart';
import 'package:segundo_cogni/features/evaluator/data/evaluator_constants.dart';
import 'package:segundo_cogni/features/module_instance/data/module_instance_constants.dart';
import 'package:segundo_cogni/features/participant/data/participant_constants.dart';
import 'package:segundo_cogni/features/recording_file/data/recording_file_constants.dart';
import 'package:segundo_cogni/features/task/domain/task_entity.dart';
import 'package:segundo_cogni/features/task_instance/data/task_instance_constants.dart';
import 'package:segundo_cogni/seeders/modules/modules_seeds.dart';
import 'package:segundo_cogni/seeders/tasks/task_seeds.dart';

Future<void> main() async {
  await DeterministicEncryptionHelper.init();

  final sqlFile = File('lib/fake_prod_seed_encrypted.sql');
  final credentialsFile = File('lib/evaluator_credentials.txt');

  final buffer = StringBuffer();
  final credentialsBuffer = StringBuffer();
  final random = Random(42);
  final now = DateTime.now();

  credentialsBuffer
    ..writeln('--- Evaluator Credentials (Generated) ---')
    ..writeln('Generated at: ${now.toIso8601String()}')
    ..writeln('-----------------------------------');

  final Map<int, List<TaskEntity>> tasksByModule = {};
  for (final t in tasksList) {
    tasksByModule.putIfAbsent(t.moduleID, () => []).add(t);
  }

  var nextEvaluatorId = 2;
  var nextParticipantId = 1;
  var nextEvaluationId = 1;
  var nextModuleInstanceId = 1;
  var nextTaskInstanceId = 1;
  var nextRecordingId = 1;

  final firstNames = [
    'Ana', 'Bruno', 'Carla', 'Diego', 'Eduarda',
    'Felipe', 'Gabriela', 'Henrique', 'Isabela', 'João',
    'Karen', 'Lucas', 'Marina', 'Nicolas', 'Otávio',
    'Patrícia', 'Rafael', 'Sara',
  ];

  final lastNames = [
    'Silva', 'Pereira', 'Souza', 'Oliveira',
    'Almeida', 'Costa', 'Lima', 'Gomes',
  ];

  String pick(List<String> list, Random r) => list[r.nextInt(list.length)];

  // buffer.writeln('BEGIN TRANSACTION;');
  // buffer.writeln();

  // --- EVALUATORS ---
  for (var e = 0; e < 10; e++) {
    final id = nextEvaluatorId++;
    final name = pick(firstNames, random);
    final surname = pick(lastNames, random);
    final email = '${name.toLowerCase()}.${surname.toLowerCase()}$id@example.com';
    final username = '${name[0].toLowerCase()}${surname.toLowerCase()}$id';
    const passwordPlain = '0000';

    final birthDate = _formatDate(DateTime(
      1970 + random.nextInt(25),
      1 + random.nextInt(12),
      1 + random.nextInt(28),
    ));

    final specialtyOptions = [
      'Geriatria', 'Neurologia', 'Psiquiatria',
      'Neuropsicologia', 'Fonoaudiologia',
    ];
    final specialty = pick(specialtyOptions, random);
    final cpf = '000000000$id';

    final isAdmin = 0;

    credentialsBuffer
      ..writeln('ID: $id | Name: $name $surname')
      ..writeln('Email: $email')
      ..writeln('Password: $passwordPlain')
      ..writeln('-----------------------------------');

    final encName = DeterministicEncryptionHelper.encryptText(name);
    final encSurname = DeterministicEncryptionHelper.encryptText(surname);
    final encEmail = DeterministicEncryptionHelper.encryptText(email);
    final encBirthDate = DeterministicEncryptionHelper.encryptText(birthDate);
    final encSpecialty = DeterministicEncryptionHelper.encryptText(specialty);
    final encCpf = DeterministicEncryptionHelper.encryptText(cpf);
    final encUsername = DeterministicEncryptionHelper.encryptText(username);
    final hashedPassword = DeterministicEncryptionHelper.hashPassword(passwordPlain);

    buffer.writeln(
      'INSERT INTO ${Tables.evaluators} ('
          '${EvaluatorFields.id}, ${EvaluatorFields.name}, ${EvaluatorFields.surname}, '
          '${EvaluatorFields.email}, ${EvaluatorFields.birthDate}, '
          '${EvaluatorFields.specialty}, ${EvaluatorFields.cpf}, '
          '${EvaluatorFields.username}, ${EvaluatorFields.password}, '
          '${EvaluatorFields.firstLogin}, ${EvaluatorFields.isAdmin}) VALUES ('
          '$id, ${_q(encName)}, ${_q(encSurname)}, ${_q(encEmail)}, '
          '${_q(encBirthDate)}, ${_q(encSpecialty)}, ${_q(encCpf)}, '
          '${_q(encUsername)}, ${_q(hashedPassword)}, 0, $isAdmin);',
    );
  }

  // --- PARTICIPANTS ---
  var currentEvaluatorId = 2;
  for (var e = 0; e < 10; e++) {
    final evaluatorId = currentEvaluatorId++;
    final participantCount = 8 + random.nextInt(5);

    for (var p = 0; p < participantCount; p++) {
      final participantId = nextParticipantId++;
      final evalId = nextEvaluationId++;
      final pName = pick(firstNames, random);
      final pSurname = pick(lastNames, random);
      final birthDate = _formatDate(
        DateTime(1940 + random.nextInt(45), 1 + random.nextInt(12), 1 + random.nextInt(28)),
      );

      final educationLevel = 1 + random.nextInt(5);
      final sex = 1 + random.nextInt(2);
      final laterality = 1 + random.nextInt(2);

      final encPName = DeterministicEncryptionHelper.encryptText(pName);
      final encPSurname = DeterministicEncryptionHelper.encryptText(pSurname);

      buffer.writeln(
        'INSERT INTO ${Tables.participants} ('
            '${ParticipantFields.id}, ${ParticipantFields.name}, ${ParticipantFields.surname}, '
            '${ParticipantFields.educationLevel}, ${ParticipantFields.sex}, '
            '${ParticipantFields.birthDate}, ${ParticipantFields.laterality}) VALUES ('
            '$participantId, ${_q(encPName)}, ${_q(encPSurname)}, '
            '$educationLevel, $sex, ${_q(birthDate)}, $laterality);',
      );
    }
  }

  buffer.writeln('COMMIT;');
  sqlFile.writeAsStringSync(buffer.toString());
  credentialsFile.writeAsStringSync(credentialsBuffer.toString());

  print('✅ Generated ${sqlFile.path}');
  print('🔑 Generated ${credentialsFile.path}');
}

String _q(String s) => "'${s.replaceAll("'", "''")}'";
String _formatDate(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
