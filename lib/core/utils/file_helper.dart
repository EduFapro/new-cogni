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
import 'package:path/path.dart' as p;
import '../../features/recording_file/domain/recording_file_entity.dart';

Future<void> exportParticipantsToExcel(
  List<ParticipantWithEvaluation> list, {
  required Future<List<ModuleInstanceEntity>> Function(int evaluationId)
  fetchModules,
  required Future<List<TaskInstanceEntity>> Function(int moduleId) fetchTasks,
}) async {
  final excel = Excel.createExcel();
  // We'll rename the default sheet later or use it as Summary

  // Summary Sheet
  final summarySheet = excel['Resumo'];
  excel.delete('Sheet1'); // Remove default if possible

  summarySheet.appendRow([
    TextCellValue('Nome'),
    TextCellValue('Status'),
    TextCellValue('Data da Avaliação'),
  ]);

  for (final p in list) {
    summarySheet.appendRow([
      TextCellValue(p.fullName),
      TextCellValue(p.statusLabel),
      TextCellValue(p.evaluationDateFormatted),
    ]);
  }

  // Individual Sheets
  for (final p in list) {
    // Generate a unique safe sheet name (Excel limit ~31 chars)
    // We'll use "Lastname_Firstname" truncated
    String sheetName = '${p.participant.surname}_${p.participant.name}'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '');
    if (sheetName.length > 30) sheetName = sheetName.substring(0, 30);

    // Check duplicates? Excel handles duplicates by erroring or auto-renaming?
    // safe approach: simple dedup check could be added but let's assume unique enough for now or let package handle.
    // Actually current package might overwrite. Let's trust unique names or add ID if needed.

    final sheet = excel[sheetName];

    // Fetch data
    List<ModuleInstanceEntity> modules = [];
    Map<int, List<TaskInstanceEntity>> tasksByModule = {};

    if (p.evaluation != null) {
      modules = await fetchModules(p.evaluation!.evaluationID!);
      for (final m in modules) {
        if (m.id != null) {
          final tasks = await fetchTasks(m.id!);
          tasksByModule[m.id!] = tasks;
        }
      }
    }

    _writeParticipantToSheet(sheet, p, modules, tasksByModule);
  }

  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filePath = '${directory.path}/Relatorio_Geral_$timestamp.xlsx';

  final fileBytes = excel.encode();
  if (fileBytes == null) return;

  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes);

  debugPrint('📁 Exported ALL to $filePath');
}

Future<void> exportSingleParticipantToExcel(
  ParticipantWithEvaluation participant, {
  String? evaluatorName,
  List<ModuleInstanceEntity>? modules,
  Map<int, List<TaskInstanceEntity>>? tasksByModule,
}) async {
  final excel = Excel.createExcel();
  final sheet = excel['Relatório'];
  excel.delete('Sheet1');

  _writeParticipantToSheet(
    sheet,
    participant,
    modules ?? [],
    tasksByModule ?? {},
  );

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

void _writeParticipantToSheet(
  Sheet sheet,
  ParticipantWithEvaluation participant,
  List<ModuleInstanceEntity> modules,
  Map<int, List<TaskInstanceEntity>> tasksByModule,
) {
  // Helper to add a styled header row
  void addHeader(String text) {
    sheet.appendRow([TextCellValue(text)]);
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
  addKeyValue('Data Cadastro:', participant.participant.creationDate ?? '-');
  sheet.appendRow([TextCellValue('')]); // Spacer

  // --- 2. Resumo da Avaliação ---
  addHeader('RESUMO DA AVALIAÇÃO');
  addKeyValue('Status:', participant.statusLabel);
  addKeyValue(
    'Data Criação (Agendamento):',
    participant.evaluation?.creationDate ?? '-',
  );
  addKeyValue(
    'Data de Início (Realizada):',
    participant.evaluationDateFormatted,
  );
  addKeyValue(
    'Data de Conclusão:',
    participant.evaluation?.completionDate ?? '-',
  );
  sheet.appendRow([TextCellValue('')]); // Spacer

  // --- 3. Detalhes dos Módulos e Tarefas ---
  if (modules.isNotEmpty) {
    addHeader('DETALHAMENTO');

    // Table Header
    sheet.appendRow([
      TextCellValue('Módulo'),
      TextCellValue('Status do Módulo'),
      TextCellValue('Conclusão Módulo'),
      TextCellValue('Tarefa'),
      TextCellValue('Status da Tarefa'),
      TextCellValue('Conclusão Tarefa'),
      TextCellValue('Tempo (s)'),
    ]);

    for (final module in modules) {
      final moduleTitle = module.module?.title ?? 'Módulo ${module.moduleId}';
      final moduleStatus = module.status == ModuleStatus.completed
          ? 'Concluído'
          : 'Pendente';
      final moduleDate = module.completionDate ?? '-';

      final tasks = tasksByModule[module.id] ?? [];

      if (tasks.isEmpty) {
        // Print just module info
        sheet.appendRow([
          TextCellValue(moduleTitle),
          TextCellValue(moduleStatus),
          TextCellValue(moduleDate),
          TextCellValue('-'),
          TextCellValue('-'),
          TextCellValue('-'),
          TextCellValue('-'),
        ]);
      } else {
        for (final task in tasks) {
          final taskTitle = task.task?.title ?? 'Tarefa ${task.taskId}';
          final taskStatus = task.status == TaskStatus.completed
              ? 'Concluída'
              : 'Pendente';
          final taskDate = task.completionDate ?? '-';
          final time = task.executionDuration ?? '-';

          sheet.appendRow([
            TextCellValue(moduleTitle),
            TextCellValue(moduleStatus),
            TextCellValue(moduleDate),
            TextCellValue(taskTitle),
            TextCellValue(taskStatus),
            TextCellValue(taskDate),
            TextCellValue(time),
          ]);
        }
      }
    }
  } else {
    sheet.appendRow([TextCellValue('Nenhum detalhe de módulo disponível.')]);
  }
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

      // Use package:path to safely extract the filename
      // This handles both / and \ separators correctly
      final filenameEnc = p.basename(encryptedPath);
      final filename = filenameEnc.replaceAll('.enc', '');

      // Use p.join to construct the destination path safely
      final destinationPath = p.join(grandParentDir.path, filename);

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
