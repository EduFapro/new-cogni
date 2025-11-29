import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logger/app_logger.dart';

/// Helper for generating organized file paths for audio recordings.
///
/// File structure:
/// Documents/Cognivoice/Avaliador_<name>/Paciente_<name>/A01_P05_T3_26112025.aac
class RecordingFilePathHelper {
  /// Generates a properly structured file path for an audio recording.
  ///
  /// Parameters:
  /// - evaluatorId: ID of the evaluator (will be zero-padded to 2 digits)
  /// - evaluatorName: Name of the evaluator (for folder name)
  /// - participantId: ID of the participant (will be zero-padded to 2 digits)
  /// - participantName: Name of the participant (for folder name)
  /// - taskEntityId: ID of the task entity (not padded)
  ///
  /// Returns the full path where the recording should be saved.
  /// Creates all necessary directories if they don't exist.
  ///
  /// Example output:
  /// C:/Users/user/Documents/Cognivoice/Avaliador_JoaoSilva/Paciente_MariaSantos/A01_P05_T3_26112025.aac
  static Future<String> generateRecordingPath({
    required int evaluatorId,
    required String evaluatorName,
    required int participantId,
    required String participantName,
    required int taskEntityId,
  }) async {
    try {
      // Get Documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      AppLogger.info('📁 Documents directory: ${documentsDir.path}');

      // Sanitize names (remove special characters, spaces become underscores)
      final sanitizedEvaluatorName = _sanitizeName(evaluatorName);
      final sanitizedParticipantName = _sanitizeName(participantName);

      // Build folder structure
      final cognivoicePath = '${documentsDir.path}/Cognivoice';
      final evaluatorPath = '$cognivoicePath/Avaliador_$sanitizedEvaluatorName';
      final participantPath =
          '$evaluatorPath/Paciente_$sanitizedParticipantName';

      // Create directories if they don't exist
      final participantDir = Directory(participantPath);
      if (!await participantDir.exists()) {
        await participantDir.create(recursive: true);
        AppLogger.info('✅ Created directory structure: $participantPath');
      }

      // Generate filename
      final formattedEvaluatorId = evaluatorId.toString().padLeft(2, '0');
      final formattedParticipantId = participantId.toString().padLeft(2, '0');
      final dateString = DateFormat('ddMMyyyy').format(DateTime.now());

      final filename =
          'A${formattedEvaluatorId}_P${formattedParticipantId}_T${taskEntityId}_$dateString.aac';

      // Full path with forward slashes (works on both Windows and Unix)
      final fullPath = '$participantPath/$filename';

      // Normalize path separators
      final normalizedPath = fullPath.replaceAll('\\', '/');

      AppLogger.info('📝 Generated recording path: $normalizedPath');
      return normalizedPath;
    } catch (e, s) {
      AppLogger.error('❌ Failed to generate recording path', e, s);
      rethrow;
    }
  }

  /// Sanitizes a name for use in folder/file names.
  /// Removes special characters and replaces spaces with underscores.
  static String _sanitizeName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .trim();
  }
}
