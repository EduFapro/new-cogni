// bin/generate_fake_prod_seed.dart  (for example)
//
// dart run bin/generate_fake_prod_seed.dart
//
// This will create fake_prod_seed.sql in the current working directory,
// with INSERTs for evaluators, participants, evaluations, module_instances,
// task_instances and recordings.

// Adjust these imports to your project structure.
// They are written assuming something similar to your existing seeds.

import 'dart:io';
import 'dart:math';

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

void main() {
  // Change this filename if you want it somewhere else.
  final file = File('fake_prod_seed.sql');
  final buffer = StringBuffer();

  final random = Random(42); // deterministic
  final now = DateTime.now();

  // Group tasks by moduleID, using your seeds.
  final Map<int, List<TaskEntity>> tasksByModule = {};
  for (final t in tasksList) {
    tasksByModule.putIfAbsent(t.moduleID, () => []).add(t);
  }

  // ID counters (we explicitly set IDs so everything is deterministic).
  var nextEvaluatorId = 1;
  var nextParticipantId = 1;
  var nextEvaluationId = 1;
  var nextModuleInstanceId = 1;
  var nextTaskInstanceId = 1;
  var nextRecordingId = 1;

  // Some name pools for fake data.
  final firstNames = <String>[
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

  final lastNames = <String>[
    'Silva',
    'Pereira',
    'Souza',
    'Oliveira',
    'Almeida',
    'Costa',
    'Lima',
    'Gomes',
  ];

  // Small helper for random picks.
  String pick(List<String> list, Random r) =>
      list[r.nextInt(list.length)];

  // Start of SQL file.
  buffer.writeln('-- Auto-generated fake production-like seed data');
  buffer.writeln('-- Generated at ${now.toIso8601String()}');
  buffer.writeln('BEGIN TRANSACTION;');
  buffer.writeln();

  // ------------------------------------------------------------
  // EVALUATORS
  // ------------------------------------------------------------

  for (var e = 0; e < 10; e++) {
    final id = nextEvaluatorId++;
    final name = pick(firstNames, random);
    final surname = pick(lastNames, random);
    final email =
        '${name.toLowerCase()}.${surname.toLowerCase()}$id@example.com';
    final username =
        '${name[0].toLowerCase()}${surname.toLowerCase()}$id';

    final birthDate = _formatDate(
      DateTime(
        1970 + random.nextInt(25), // 1970–1994
        1 + random.nextInt(12),
        1 + random.nextInt(28),
      ),
    );

    final specialtyOptions = <String>[
      'Geriatria',
      'Neurologia',
      'Psiquiatria',
      'Neuropsicologia',
      'Fonoaudiologia',
    ];
    final specialty = pick(specialtyOptions, random);
    final cpf = '000000000$id';

    final isAdmin = (id == 1) ? 1 : 0;

    buffer.writeln('INSERT INTO ${Tables.evaluators} ('
        '${EvaluatorFields.id}, '
        '${EvaluatorFields.name}, '
        '${EvaluatorFields.surname}, '
        '${EvaluatorFields.email}, '
        '${EvaluatorFields.birthDate}, '
        '${EvaluatorFields.specialty}, '
        '${EvaluatorFields.cpf}, '
        '${EvaluatorFields.username}, '
        '${EvaluatorFields.password}, '
        '${EvaluatorFields.firstLogin}, '
        '${EvaluatorFields.isAdmin}'
        ') VALUES ('
        '$id, '
        '${_q(name)}, '
        '${_q(surname)}, '
        '${_q(email)}, '
        '${_q(birthDate)}, '
        '${_q(specialty)}, '
        '${_q(cpf)}, '
        '${_q(username)}, '
    // plaintext; in your app you usually store an encrypted hash,
    // but for dev data "0000" is fine.
        '${_q('0000')}, '
        '0, ' // first_login = false
        '$isAdmin'
        ');');
  }

  buffer.writeln();
  // ------------------------------------------------------------
  // PARTICIPANTS + EVALUATIONS + MODULE_INSTANCES + TASK_INSTANCES + RECORDINGS
  // ------------------------------------------------------------

  // Note on your schema: EvaluationFields.participantId is UNIQUE,
  // so we create 1 evaluation per participant.

  nextEvaluatorId = 1; // iterate again to assign participants per evaluator

  for (var e = 0; e < 10; e++) {
    final evaluatorId = nextEvaluatorId++;

    // 8–12 participants per evaluator
    final participantCount = 8 + random.nextInt(5);

    for (var p = 0; p < participantCount; p++) {
      final participantId = nextParticipantId++;
      final evalId = nextEvaluationId++;

      final pName = pick(firstNames, random);
      final pSurname = pick(lastNames, random);

      final birthDate = _formatDate(
        DateTime(
          1940 + random.nextInt(45), // 1940–1984
          1 + random.nextInt(12),
          1 + random.nextInt(28),
        ),
      );

      final educationLevel = 1 + random.nextInt(5); // 1..5
      final sex = 1 + random.nextInt(2); // 1..2
      final laterality = 1 + random.nextInt(2); // 1..2

      // Insert participant
      buffer.writeln('INSERT INTO ${Tables.participants} ('
          '${ParticipantFields.id}, '
          '${ParticipantFields.name}, '
          '${ParticipantFields.surname}, '
          '${ParticipantFields.educationLevel}, '
          '${ParticipantFields.sex}, '
          '${ParticipantFields.birthDate}, '
          '${ParticipantFields.laterality}'
          ') VALUES ('
          '$participantId, '
          '${_q(pName)}, '
          '${_q(pSurname)}, '
          '$educationLevel, '
          '$sex, '
          '${_q(birthDate)}, '
          '$laterality'
          ');');

      // Evaluation date in the last ~120 days
      final daysBack = random.nextInt(120);
      final baseDate = now.subtract(Duration(days: daysBack));
      final evalDate = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        8 + random.nextInt(9), // 8h–16h
        random.nextInt(60),
        0,
      );
      final evalDateStr = _formatDateTime(evalDate);

      // evaluation status: mostly completed (3), some in-progress (2) or planned (1)
      final evalStatus = _randomStatus123(random);
      // language: 1 or 2
      final language = 1 + random.nextInt(2);

      // Insert evaluation
      buffer.writeln('INSERT INTO ${Tables.evaluations} ('
          '${EvaluationFields.id}, '
          '${EvaluationFields.date}, '
          '${EvaluationFields.evaluatorId}, '
          '${EvaluationFields.participantId}, '
          '${EvaluationFields.status}, '
          '${EvaluationFields.language}'
          ') VALUES ('
          '$evalId, '
          '${_q(evalDateStr)}, '
          '$evaluatorId, '
          '$participantId, '
          '$evalStatus, '
          '$language'
          ');');

      // For this evaluation, create module_instances for all modules in modulesList.
      for (final module in modulesList) {
        final moduleInstId = nextModuleInstanceId++;

        final moduleStatus = _randomStatus123(random);

        buffer.writeln('INSERT INTO ${Tables.moduleInstances} ('
            '${ModuleInstanceFields.id}, '
            '${ModuleInstanceFields.moduleId}, '
            '${ModuleInstanceFields.evaluationId}, '
            '${ModuleInstanceFields.status}'
            ') VALUES ('
            '$moduleInstId, '
            '${module.moduleID}, '
            '$evalId, '
            '$moduleStatus'
            ');');

        // Tasks for this module
        final moduleTasks = tasksByModule[module.moduleID] ?? const [];

        for (final task in moduleTasks) {
          final taskInstId = nextTaskInstanceId++;

          final taskStatus = _randomTaskStatus(random); // 0 or 1
          final completingSeconds =
          _randomCompletingTime(random, task.taskMode);
          final completingStr = completingSeconds.toString();

          buffer.writeln('INSERT INTO ${Tables.taskInstances} ('
              '${TaskInstanceFields.id}, '
              '${TaskInstanceFields.taskId}, '
              '${TaskInstanceFields.moduleInstanceId}, '
              '${TaskInstanceFields.status}, '
              '${TaskInstanceFields.completingTime}'
              ') VALUES ('
              '$taskInstId, '
              '${task.taskID}, '
              '$moduleInstId, '
              '$taskStatus, '
              '${_q(completingStr)}'
              ');');

          // Dummy recording for this task_instance
          final recordingId = nextRecordingId++;
          final path =
              'recordings/eval_${evalId}_mod_${module.moduleID}_task_$taskInstId.wav';

          buffer.writeln('INSERT INTO ${Tables.recordings} ('
              '${RecordingFileFields.id}, '
              '${RecordingFileFields.taskInstanceId}, '
              '${RecordingFileFields.filePath}'
              ') VALUES ('
              '$recordingId, '
              '$taskInstId, '
              '${_q(path)}'
              ');');
        }

        buffer.writeln();
      }

      buffer.writeln();
    }
  }

  buffer.writeln('COMMIT;');

  file.writeAsStringSync(buffer.toString());
  // ignore: avoid_print
  print('✅ fake_prod_seed.sql generated with fake production-like data.');
}

// ----------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------

String _q(String s) {
  // SQL single-quote escape: ' -> ''
  final escaped = s.replaceAll("'", "''");
  return "'$escaped'";
}

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
  // For record tasks: 20–300s
  // For play tasks: 5–60s, mostly short
  if (mode == TaskMode.record) {
    return 20 + r.nextInt(280);
  } else {
    return 5 + r.nextInt(55);
  }
}
