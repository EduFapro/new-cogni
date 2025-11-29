import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/recording_file_entity.dart';

class RecordingFileRemoteDataSource {
  final NetworkService _networkService;

  RecordingFileRemoteDataSource(this._networkService);

  Future<int?> createRecordingFile(RecordingFileEntity recording) async {
    try {
      final response = await _networkService.post(
        '/api/recordings',
        recording.toJsonForApi(),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create recording file on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing recording file to backend', e, s);
      return null;
    }
  }
}
