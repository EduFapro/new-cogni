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

  // Group tasks by module id
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
    'Ana',
    'Bruno',
    'Carla',
    'Diego',
    'Eduarda',
    'Felipe',
    'Gabriela',
    'Henrique',
    'Isabela',
    'João',
    'Karen',
    'Lucas',
    'Marina',
    'Nicolas',
    'Otávio',
    'Patrícia',
    'Rafael',
    'Sara',
  ];

  final lastNames = [
    'Silva',
    'Pereira',
    'Souza',
    'Oliveira',
    'Almeida',
    'Costa',
    'Lima',
    'Gomes',
  ];

  String pick(List<String> list, Random r) => list[r.nextInt(list.length)];

  // If you want explicit transaction markers in the SQL file, uncomment:
  // buffer.writeln('BEGIN TRANSACTION;');
  // buffer.writeln();

  // ---------------------- EVALUATORS ----------------------
  for (var e = 0; e < 10; e++) {
    final id = nextEvaluatorId++;
    final name = pick(firstNames, random);
    final surname = pick(lastNames, random);
    final email =
        '${name.toLowerCase()}.${surname.toLowerCase()}$id@example.com';
    final username = '${name[0].toLowerCase()}${surname.toLowerCase()}$id';
    const passwordPlain = '0000';

    final birthDate = _formatDate(
      DateTime(
        1970 + random.nextInt(25),
        1 + random.nextInt(12),
        1 + random.nextInt(28),
      ),
    );

    final specialtyOptions = [
      'Geriatria',
      'Neurologia',
      'Psiquiatria',
      'Neuropsicologia',
      'Fonoaudiologia',
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
    final hashedPassword = DeterministicEncryptionHelper.hashPassword(
      passwordPlain,
    );

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

  // ---------------------- PARTICIPANTS + EVALUATIONS + MODULES + TASKS ----------------------
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
        DateTime(
          1940 + random.nextInt(45),
          1 + random.nextInt(12),
          1 + random.nextInt(28),
        ),
      );

      final educationLevel = 1 + random.nextInt(5);
      final sex = 1 + random.nextInt(2);
      final laterality = 1 + random.nextInt(2);

      final encPName = DeterministicEncryptionHelper.encryptText(pName);
      final encPSurname = DeterministicEncryptionHelper.encryptText(pSurname);

      // Participant row
      buffer.writeln(
        'INSERT INTO ${Tables.participants} ('
        '${ParticipantFields.id}, ${ParticipantFields.name}, ${ParticipantFields.surname}, '
        '${ParticipantFields.educationLevel}, ${ParticipantFields.sex}, '
        '${ParticipantFields.birthDate}, ${ParticipantFields.laterality}) VALUES ('
        '$participantId, ${_q(encPName)}, ${_q(encPSurname)}, '
        '$educationLevel, $sex, ${_q(birthDate)}, $laterality);',
      );

      // ----- Evaluation row -----
      final daysBack = random.nextInt(120);
      final baseDate = now.subtract(Duration(days: daysBack));
      final evalDate = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        8 + random.nextInt(9), // 8–16h
        random.nextInt(60),
        0,
      );
      final evalDateStr = _formatDateTime(evalDate);

      final evalStatus = _randomStatus123(random); // 1,2,3
      final language = 1 + random.nextInt(2); // 1 or 2

      buffer.writeln(
        'INSERT INTO ${Tables.evaluations} ('
        '${EvaluationFields.id}, ${EvaluationFields.date}, '
        '${EvaluationFields.evaluatorId}, ${EvaluationFields.participantId}, '
        '${EvaluationFields.status}, ${EvaluationFields.language}) VALUES ('
        '$evalId, ${_q(evalDateStr)}, '
        '$evaluatorId, $participantId, '
        '$evalStatus, $language);',
      );

      // ----- Module instances + task instances + recordings -----
      for (final module in modulesList) {
        final moduleInstId = nextModuleInstanceId++;
        final moduleStatus = _randomStatus123(random);

        // module_instance row
        buffer.writeln(
          'INSERT INTO ${Tables.moduleInstances} ('
          '${ModuleInstanceFields.id}, ${ModuleInstanceFields.moduleId}, '
          '${ModuleInstanceFields.evaluationId}, ${ModuleInstanceFields.status}) VALUES ('
          '$moduleInstId, ${module.moduleID}, $evalId, $moduleStatus);',
        );

        // tasks of this module
        final moduleTasks =
            tasksByModule[module.moduleID] ?? const <TaskEntity>[];

        for (final task in moduleTasks) {
          final taskInstId = nextTaskInstanceId++;
          final taskStatus = _randomTaskStatus(random); // 0 or 1
          final completingSeconds = _randomCompletingTime(
            random,
            task.taskMode,
          );
          final completingStr = completingSeconds.toString();

          // task_instance
          buffer.writeln(
            'INSERT INTO ${Tables.taskInstances} ('
            '${TaskInstanceFields.id}, ${TaskInstanceFields.taskId}, '
            '${TaskInstanceFields.moduleInstanceId}, '
            '${TaskInstanceFields.status}, ${TaskInstanceFields.executionDuration}) VALUES ('
            '$taskInstId, ${task.taskID}, $moduleInstId, '
            '$taskStatus, ${_q(completingStr)});',
          );

          // dummy recording row
          final recordingId = nextRecordingId++;
          final path =
              'recordings/eval_${evalId}_mod_${module.moduleID}_task_$taskInstId.wav';

          buffer.writeln(
            'INSERT INTO ${Tables.recordings} ('
            '${RecordingFileFields.id}, ${RecordingFileFields.taskInstanceId}, '
            '${RecordingFileFields.filePath}) VALUES ('
            '$recordingId, $taskInstId, ${_q(path)});',
          );
        }
      }
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

String _formatDateTime(DateTime dt) =>
    '${_formatDate(dt)} '
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}:'
    '${dt.second.toString().padLeft(2, '0')}';

int _randomStatus123(Random r) {
  final roll = r.nextInt(100);
  if (roll < 10) return 1; // ~10% status 1
  if (roll < 30) return 2; // ~20% status 2
  return 3; // ~70% status 3
}

int _randomTaskStatus(Random r) {
  // 80% completed(1), 20% not completed(0)
  return r.nextInt(100) < 80 ? 1 : 0;
}

int _randomCompletingTime(Random r, TaskMode mode) {
  if (mode == TaskMode.record) {
    return 20 + r.nextInt(280); // 20–300s
  } else {
    return 5 + r.nextInt(55); // 5–60s
  }
}
