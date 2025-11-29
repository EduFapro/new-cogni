import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/task_instance_entity.dart';

class TaskInstanceRemoteDataSource {
  final NetworkService _networkService;

  TaskInstanceRemoteDataSource(this._networkService);

  Future<int?> createTaskInstance(TaskInstanceEntity instance) async {
    try {
      final response = await _networkService.post(
        '/api/task-instances',
        instance.toJsonForApi(),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create task instance on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing task instance to backend', e, s);
      return null;
    }
  }

  Future<bool> markAsCompleted(int id, String? duration) async {
    try {
      final response = await _networkService.patch(
        '/api/task-instances/$id/complete',
        {'duration': duration},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to mark task as completed on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error marking task as completed on backend', e, s);
      return false;
    }
  }
}
