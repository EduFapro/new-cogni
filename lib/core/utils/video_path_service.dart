import '../../features/evaluation/domain/evaluation_entity.dart';
import '../../features/task/domain/task_entity.dart';

class VideoPathService {
  /// Resolves the video path dynamically by searching available assets.
  ///
  /// [allAssets] should be a list of all available asset paths (from AssetManifest).
  static String? resolveVideoPath({
    required TaskEntity task,
    required EvaluationEntity evaluation,
    required List<String> allAssets,
  }) {
    final avatar = evaluation.avatar;
    final moduleFolder = _getModuleFolder(task.moduleID);

    // Expected directory prefix
    final dirPrefix = 'assets/video/task_prompts/$avatar/$moduleFolder/';

    // Target ID: {MM}{TT} (Module ID + Task Position, padded)
    final mm = task.moduleID.toString().padLeft(2, '0');
    final tt = task.position.toString().padLeft(2, '0');
    final targetId = '$mm$tt';

    // Search for matching file
    for (final assetPath in allAssets) {
      // 1. Must be in the correct folder
      if (!assetPath.startsWith(dirPrefix)) continue;

      // 2. Extract filename
      final filename = assetPath.split('/').last;
      final nameWithoutExt = filename.split('.').first;

      // 3. Check if filename contains the target ID in its prefix parts
      // Example: "0212-0214-0216-name" -> parts: ["0212", "0214", "0216", "name"]
      final parts = nameWithoutExt.split('-');

      for (final part in parts) {
        // If we hit a non-numeric part (like "name"), stop checking this file?
        // Or just check if ANY part matches targetId.
        // Given "0212-0214-0216", checking all parts is safer.
        if (part == targetId) {
          return assetPath;
        }
      }
    }

    return null;
  }

  /// Maps module ID to the corresponding folder name.
  static String _getModuleFolder(int moduleID) {
    switch (moduleID) {
      case 1: // Sociodemographic
        return '01-Dados_Pessoais';
      case 2: // Cognitive Functions
        return '02-Funcoes_Cognitivas';
      case 3: // Functionality
        return '03-Funcionalidade';
      case 4: // Depression Symptoms
        return '04-SIntomas_de_Depressao';
      case 5: // Tests (if applicable)
        return '05-Testes';
      default:
        return 'Unknown_Module';
    }
  }
}
