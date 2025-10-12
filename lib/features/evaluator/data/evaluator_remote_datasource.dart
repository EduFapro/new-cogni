import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/logger/app_logger.dart';
import 'evaluator_model.dart';

class EvaluatorRemoteDataSource {
  final String baseUrl = 'https://api.example.com/evaluators';

  Future<List<EvaluatorModel>> fetchAllEvaluators() async {
    final url = Uri.parse(baseUrl);
    AppLogger.info('HTTP GET → $url');
    try {
      final response = await http.get(url);
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EvaluatorModel.fromMap(e)).toList();
      } else {
        AppLogger.warning('Failed to fetch evaluators: ${response.body}');
        return [];
      }
    } catch (e, s) {
      AppLogger.error('Error fetching evaluators from API', e, s);
      return [];
    }
  }

  Future<void> createEvaluator(EvaluatorModel evaluator) async {
    final url = Uri.parse(baseUrl);
    final body = jsonEncode(evaluator.toMap());
    AppLogger.info('HTTP POST → $url | body: $body');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      AppLogger.info('HTTP ${response.statusCode} ← $url');
      if (response.statusCode >= 400) {
        AppLogger.warning('Error creating evaluator: ${response.body}');
      }
    } catch (e, s) {
      AppLogger.error('HTTP POST failed for evaluator ${evaluator.email}', e, s);
    }
  }
}
