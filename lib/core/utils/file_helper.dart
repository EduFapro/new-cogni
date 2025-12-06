import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../features/participant/domain/participant_with_evaluation.dart';
import '../../features/module_instance/domain/module_instance_entity.dart';
import '../../features/task_instance/domain/task_instance_entity.dart';
import '../../core/constants/enums/progress_status.dart';
import '../../core/constants/enums/person_enums.dart';
import '../../core/constants/enums/laterality_enums.dart';
import 'package:intl/intl.dart';

Future<void> exportParticipantsToExcel(
  List<ParticipantWithEvaluation> list,
) async {
  final excel = Excel.createExcel();
  final sheet = excel['Pacientes'];

  // Header
  sheet.appendRow([
    TextCellValue('Nome'),
    TextCellValue('Status'),
    TextCellValue('Data da Avaliação'),
  ]);

  // Rows
  for (final p in list) {
    sheet.appendRow([
      TextCellValue(p.fullName),
      TextCellValue(p.statusLabel),
      TextCellValue(p.evaluationDateFormatted),
    ]);
  }

  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/pacientes_exportados.xlsx';

  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes);

  debugPrint('📁 Exported to $filePath');
}

Future<void> exportSingleParticipantToExcel(
  ParticipantWithEvaluation participant, {
  String? evaluatorName,
  List<ModuleInstanceEntity>? modules,
  Map<int, List<TaskInstanceEntity>>? tasksByModule,
}) async {
  final excel = Excel.createExcel();
  final sheet = excel['Relatório'];

  // Remove default sheet if possible or just use 'Relatório'
  excel.delete('Sheet1');

  // Helper to add a styled header row
  void addHeader(String text) {
    sheet.appendRow([TextCellValue(text)]);
    // Note: styling is limited in this package version, but we structure it well.
  }

  // Helper to add a key-value row
  void addKeyValue(String key, String value) {
    sheet.appendRow([TextCellValue(key), TextCellValue(value)]);
  }

  // --- 1. Dados Pessoais ---
  addHeader('DADOS PESSOAIS');
  addKeyValue('Nome Completo:', participant.fullName);
  addKeyValue(
    'Data de Nascimento:',
    DateFormat('dd/MM/yyyy').format(participant.participant.birthDate),
  );
  addKeyValue('Sexo:', participant.participant.sex.label);
  addKeyValue('Escolaridade:', participant.participant.educationLevel.label);
  addKeyValue('Lateralidade:', participant.participant.laterality.label);
  sheet.appendRow([TextCellValue('')]); // Spacer

  // --- 2. Resumo da Avaliação ---
  addHeader('RESUMO DA AVALIAÇÃO');
  addKeyValue('Status:', participant.statusLabel);
  addKeyValue('Data da Avaliação:', participant.evaluationDateFormatted);
  sheet.appendRow([TextCellValue('')]); // Spacer

  // --- 3. Detalhes dos Módulos e Tarefas ---
  if (modules != null && modules.isNotEmpty) {
    addHeader('DETALHAMENTO');

    // Table Header
    sheet.appendRow([
      TextCellValue('Módulo'),
      TextCellValue('Status do Módulo'),
      TextCellValue('Tarefa'),
      TextCellValue('Status da Tarefa'),
      TextCellValue('Tempo (s)'),
    ]);

    for (final module in modules) {
      final moduleTitle = module.module?.title ?? 'Módulo ${module.moduleId}';
      final moduleStatus = module.status == ModuleStatus.completed
          ? 'Concluído'
          : 'Pendente';

      final tasks = tasksByModule?[module.id] ?? [];

      if (tasks.isEmpty) {
        // Print just module info
        sheet.appendRow([
          TextCellValue(moduleTitle),
          TextCellValue(moduleStatus),
          TextCellValue('-'),
          TextCellValue('-'),
          TextCellValue('-'),
        ]);
      } else {
        // Print module info on first task row, or separate?
        // Let's print module info for every task for easier filtering in Excel
        for (final task in tasks) {
          final taskTitle = task.task?.title ?? 'Tarefa ${task.taskId}';
          final taskStatus = task.status == TaskStatus.completed
              ? 'Concluída'
              : 'Pendente';
          final time = task.completingTime ?? '-';

          sheet.appendRow([
            TextCellValue(moduleTitle),
            TextCellValue(moduleStatus),
            TextCellValue(taskTitle),
            TextCellValue(taskStatus),
            TextCellValue(time),
          ]);
        }
      }
    }
  } else {
    sheet.appendRow([TextCellValue('Nenhum detalhe de módulo disponível.')]);
  }

  final directory = await getApplicationDocumentsDirectory();

  // Create organized folder structure: Documents/Cognivoice/Avaliador_<name>/Paciente_<name>/
  final cognivoiceDir = Directory('${directory.path}/Cognivoice');
  if (!await cognivoiceDir.exists()) {
    await cognivoiceDir.create(recursive: true);
  }

  // Add evaluator folder if name is provided
  String basePath = cognivoiceDir.path;
  if (evaluatorName != null && evaluatorName.isNotEmpty) {
    final evaluatorDir = Directory('$basePath/Avaliador_$evaluatorName');
    if (!await evaluatorDir.exists()) {
      await evaluatorDir.create(recursive: true);
    }
    basePath = evaluatorDir.path;
  }

  final participantDir = Directory(
    '$basePath/Paciente_${participant.fullName}',
  );
  if (!await participantDir.exists()) {
    await participantDir.create(recursive: true);
  }

  final filePath =
      '${participantDir.path}/participante_${participant.fullName}.xlsx';

  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes);

  debugPrint('📁 Exported single participant to $filePath');
}
