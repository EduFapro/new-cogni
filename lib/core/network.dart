import 'dart:convert';

import 'package:http/http.dart' as http;

import 'logger/app_logger.dart';

class NetworkService {
  final String baseUrl = 'https://api.example.com';

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP GET → $url');

    try {
      final response = await http.get(url);
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      if (response.statusCode >= 400) {
        AppLogger.warning('HTTP error ${response.statusCode}: ${response.body}');
      }
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP GET failed for $url', e, s);
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    AppLogger.info('HTTP POST → $url body=$body');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      if (response.statusCode >= 400) {
        AppLogger.warning('HTTP error ${response.statusCode}: ${response.body}');
      }
      return response;
    } catch (e, s) {
      AppLogger.error('HTTP POST failed for $url', e, s);
      rethrow;
    }
  }
}
