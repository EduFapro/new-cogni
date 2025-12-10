import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'logger/app_logger.dart';

class NetworkService {
  final String baseUrl;
  final bool syncEnabled;
  final String? apiSecret;

  NetworkService()
    : baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080',
      syncEnabled = dotenv.env['ENABLE_SYNC']?.toLowerCase() == 'true',
      apiSecret = dotenv.env['API_SECRET'];

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
    AppLogger.info(
      '[NetworkService] 🔑 Token set: ${token != null ? "Yes" : "No"}',
    );
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (apiSecret != null) {
      headers['X-API-KEY'] = apiSecret!;
    }
    return headers;
  }

  void _logError(http.Response response) {
    if (response.statusCode >= 400) {
      String message = 'HTTP error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body.containsKey('error')) {
            message += ': ${body['error']}';
          }
          if (body.containsKey('details')) {
            message += ' | Details: ${body['details']}';
          }
        } else {
          message += ': ${response.body}';
        }
      } catch (_) {
        message += ': ${response.body}';
      }
      AppLogger.warning(message);
    }
  }

  Future<http.Response> get(String endpoint) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP GET → $url');

    try {
      final response = await http.get(url, headers: _headers);
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      _logError(response);
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP GET failed for $url', e, s);
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP POST → $url');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      _logError(response);
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP POST failed for $url', e, s);
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP PUT → $url');

    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      _logError(response);
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP PUT failed for $url', e, s);
      rethrow;
    }
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP PATCH → $url');

    try {
      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      _logError(response);
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP PATCH failed for $url', e, s);
      rethrow;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP DELETE → $url');

    try {
      final response = await http.delete(url, headers: _headers);
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      _logError(response);
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP DELETE failed for $url', e, s);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> checkBackendStatus() async {
    if (!syncEnabled) return null;

    final url = Uri.parse('$baseUrl/api/status');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.warning('Failed to check backend status: $e');
    }
    return null;
  }
}
