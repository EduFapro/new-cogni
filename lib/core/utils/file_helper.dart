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
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../shared/encryption/file_encryption_helper.dart';
import '../../features/recording_file/domain/recording_file_entity.dart';

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
          final time = task.executionDuration ?? '-';

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

  // Helper for snake_case
  String _toSnakeCase(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
  }

  // Create organized folder structure: Documents/Cognivoice/avaliador_<name>/
  final cognivoiceDir = Directory('${directory.path}/Cognivoice');
  if (!await cognivoiceDir.exists()) {
    await cognivoiceDir.create(recursive: true);
  }

  // Add evaluator folder if name is provided
  String basePath = cognivoiceDir.path;
  if (evaluatorName != null && evaluatorName.isNotEmpty) {
    final folderName = _toSnakeCase('avaliador_$evaluatorName');
    final evaluatorDir = Directory('$basePath/$folderName');
    if (!await evaluatorDir.exists()) {
      await evaluatorDir.create(recursive: true);
    }
    basePath = evaluatorDir.path;
  }

  // File name: paciente_<name>.xlsx (snake_case)
  final fileName = _toSnakeCase('paciente_${participant.fullName}') + '.xlsx';
  final filePath = '$basePath/$fileName';

  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes);

  debugPrint('📁 Exported single participant to $filePath');
}

/// Checks if legacy data cleanup is needed.
/// Returns true if DB is missing but Cognivoice folder exists.
Future<bool> checkLegacyData() async {
  try {
    // 1. Check if Database exists
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final dbFile = File('$dbPath/cognivoice_db.db');
    final dbExists = await dbFile.exists();

    if (dbExists) return false;

    // 2. Check if Cognivoice folder exists
    final directory = await getApplicationDocumentsDirectory();
    final cognivoiceDir = Directory('${directory.path}/Cognivoice');

    return await cognivoiceDir.exists();
  } catch (e) {
    debugPrint('❌ [CLEANUP] Error checking legacy data: $e');
    return false;
  }
}

/// Performs the cleanup of the legacy Cognivoice folder.
Future<void> performLegacyCleanup() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final cognivoiceDir = Directory('${directory.path}/Cognivoice');

    if (await cognivoiceDir.exists()) {
      debugPrint('⚠️ [CLEANUP] Deleting legacy folder: ${cognivoiceDir.path}');
      await cognivoiceDir.delete(recursive: true);
      debugPrint('✅ [CLEANUP] Legacy folder deleted successfully.');
    }
  } catch (e) {
    debugPrint('❌ [CLEANUP] Error performing legacy cleanup: $e');
  }
}

/// Decrypts and saves all recordings for a participant to their folder.
Future<void> downloadRecordingsForParticipant(
  ParticipantWithEvaluation participant,
  List<RecordingFileEntity> recordings,
) async {
  try {
    int successCount = 0;
    int failCount = 0;

    for (final recording in recordings) {
      final encryptedPath = recording.filePath;
      final encryptedFile = File(encryptedPath);

      if (!await encryptedFile.exists()) {
        debugPrint('⚠️ Recording file not found: $encryptedPath');
        failCount++;
        continue;
      }

      // Determine destination path (parent of .encrypted)
      // encryptedPath: .../Paciente_Name/.encrypted/file.aac.enc
      // parent: .../Paciente_Name/.encrypted
      // grandParent: .../Paciente_Name

      final parentDir = encryptedFile.parent; // .encrypted
      final grandParentDir = parentDir.parent; // Paciente_Name

      // Original filename without .enc
      // If path is .../file.aac.enc, basename is file.aac.enc
      // We want file.aac
      final filenameEnc = encryptedPath.split(Platform.pathSeparator).last;
      final filename = filenameEnc.replaceAll('.enc', '');

      final destinationPath = '${grandParentDir.path}/$filename';

      try {
        await FileEncryptionHelper.decryptFile(encryptedPath, destinationPath);
        successCount++;
      } catch (e) {
        debugPrint('❌ Failed to decrypt $filename: $e');
        failCount++;
      }
    }

    debugPrint(
      '✅ Download complete. Success: $successCount, Failed: $failCount',
    );
  } catch (e) {
    debugPrint('❌ Error downloading recordings: $e');
    rethrow;
  }
}
