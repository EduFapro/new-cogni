import 'dart:convert';
import '../../../core/logger/app_logger.dart';
import '../../../core/network.dart';
import '../domain/module_instance_entity.dart';

class ModuleInstanceRemoteDataSource {
  final NetworkService _networkService;

  ModuleInstanceRemoteDataSource(this._networkService);

  Future<int?> createModuleInstance(ModuleInstanceEntity instance) async {
    try {
      final response = await _networkService.post(
        '/api/module-instances',
        instance.toJsonForApi(),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      } else {
        AppLogger.error(
          'Failed to create module instance on backend: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.error('Error syncing module instance to backend', e, s);
      return null;
    }
  }

  Future<bool> updateModuleInstanceStatus(int id, int status) async {
    try {
      final response = await _networkService.patch(
        '/api/module-instances/$id/status',
        {'status': status},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
          'Failed to update module instance status on backend: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.error('Error updating module instance status on backend', e, s);
      return false;
    }
  }
}
