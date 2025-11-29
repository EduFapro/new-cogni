import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/evaluation_entity.dart';

class EvaluationRemoteDataSource {
  final NetworkService _networkService;

  EvaluationRemoteDataSource(this._networkService);

  Future<int?> createEvaluation(EvaluationEntity evaluation) async {
    try {
      final response = await _networkService.post('/api/evaluations', {
        'evaluatorId': evaluation.evaluatorID,
        'participantId': evaluation.participantID,
        'evaluationDate': evaluation.evaluationDate.toIso8601String(),
        'status': evaluation.status.numericValue,
        'language': evaluation.language,
      });

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create evaluation on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing evaluation to backend', e, s);
      return null;
    }
  }

  Future<bool> updateEvaluationStatus(int id, int status) async {
    try {
      final response = await _networkService.patch(
        '/api/evaluations/$id/status',
        {'status': status},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to update evaluation status on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error updating evaluation status on backend', e, s);
      return false;
    }
  }
}
