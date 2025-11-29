import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'logger/app_logger.dart';

class NetworkService {
  final String baseUrl;
  final bool syncEnabled;

  NetworkService()
    : baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080',
      syncEnabled = dotenv.env['ENABLE_SYNC']?.toLowerCase() == 'true';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<http.Response> get(String endpoint) async {
    if (!syncEnabled) {
      throw Exception('Sync is disabled');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP GET → $url');

    try {
      final response = await http.get(url, headers: _headers);
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      if (response.statusCode >= 400) {
        AppLogger.warning(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }
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
      if (response.statusCode >= 400) {
        AppLogger.warning(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }
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
      if (response.statusCode >= 400) {
        AppLogger.warning(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }
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
      if (response.statusCode >= 400) {
        AppLogger.warning(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }
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
      if (response.statusCode >= 400) {
        AppLogger.warning(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP DELETE failed for $url', e, s);
      rethrow;
    }
  }
}
