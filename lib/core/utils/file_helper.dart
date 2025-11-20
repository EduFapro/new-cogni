import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../features/participant/domain/participant_with_evaluation.dart';

Future<void> exportParticipantsToExcel(List<ParticipantWithEvaluation> list) async {
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

  final file = File(filePath)..createSync(recursive: true);
  await file.writeAsBytes(fileBytes);

  debugPrint('📁 Exported to $filePath');
}

Future<void> exportSingleParticipantToExcel(ParticipantWithEvaluation participant) async {
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
  final filePath = '${directory.path}/participante_${participant.fullName}.xlsx';

  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  final file = File(filePath)..createSync(recursive: true);
  await file.writeAsBytes(fileBytes);

  debugPrint('📁 Exported single participant to $filePath');
}
