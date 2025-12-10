import 'dart:convert';
import '../../../../core/network.dart';
import '../../../../core/logger/app_logger.dart';

class EvaluatorRemoteDataSource {
  final NetworkService _network;

  EvaluatorRemoteDataSource(this._network);

  Future<String?> login(String username, String password) async {
    try {
      final response = await _network.post('/api/evaluators/login', {
        'email':
            username, // The argument is still named username in the method, but we send it as 'email'
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String?;
      } else {
        AppLogger.warning('Remote login failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Remote login error', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEvaluatorById(int id) async {
    try {
      final response = await _network.get('/api/evaluators/$id');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        AppLogger.warning(
          'Failed to fetch remote evaluator: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error fetching remote evaluator', e);
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _network.post('/api/auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error changing password', e);
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _network.post('/api/auth/request-password-reset', {
        'email': email,
      });
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error requesting password reset', e);
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _network.post('/api/auth/reset-password', {
        'token': token,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error resetting password', e);
      return false;
    }
  }
}
