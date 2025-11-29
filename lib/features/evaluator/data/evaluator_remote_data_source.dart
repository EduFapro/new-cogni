import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/evaluator_registration_data.dart';

class EvaluatorRemoteDataSource {
  final NetworkService _networkService;

  EvaluatorRemoteDataSource(this._networkService);

  Future<int?> createEvaluator(EvaluatorRegistrationData data) async {
    try {
      final response = await _networkService.post(
        '/api/evaluators',
        data.toJson(),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create evaluator on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing evaluator to backend', e, s);
      return null;
    }
  }

  Future<bool> updateEvaluator(int id, EvaluatorRegistrationData data) async {
    try {
      final response = await _networkService.put(
        '/api/evaluators/$id',
        data.toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to update evaluator on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error updating evaluator on backend', e, s);
      return false;
    }
  }

  Future<bool> deleteEvaluator(int id) async {
    try {
      final response = await _networkService.delete('/api/evaluators/$id');

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to delete evaluator on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error deleting evaluator from backend', e, s);
      return false;
    }
  }
}
