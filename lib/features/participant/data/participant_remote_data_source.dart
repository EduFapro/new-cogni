import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/participant_entity.dart';

class ParticipantRemoteDataSource {
  final NetworkService _networkService;

  ParticipantRemoteDataSource(this._networkService);

  Future<int?> createParticipant(
    ParticipantEntity participant,
    int evaluatorId,
  ) async {
    try {
      final response = await _networkService.post(
        '/api/participants',
        participant.toJsonForApi(evaluatorId: evaluatorId),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create participant on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing participant to backend', e, s);
      return null;
    }
  }

  Future<bool> updateParticipant(
    int id,
    ParticipantEntity participant,
    int evaluatorId,
  ) async {
    try {
      final response = await _networkService.put(
        '/api/participants/$id',
        participant.toJsonForApi(evaluatorId: evaluatorId),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to update participant on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error updating participant on backend', e, s);
      return false;
    }
  }

  Future<bool> deleteParticipant(int id) async {
    try {
      final response = await _networkService.delete('/api/participants/$id');

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to delete participant on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error deleting participant from backend', e, s);
      return false;
    }
  }
}
