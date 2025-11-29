import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../features/participant/domain/participant_with_evaluation.dart';

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
}) async {
  final excel = Excel.createExcel();
  final sheet = excel['Participante'];

  sheet.appendRow([
    TextCellValue('Nome'),
    TextCellValue('Status'),
    TextCellValue('Data da Avaliação'),
  ]);

  sheet.appendRow([
    TextCellValue(participant.fullName),
    TextCellValue(participant.statusLabel),
    TextCellValue(participant.evaluationDateFormatted),
  ]);

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
