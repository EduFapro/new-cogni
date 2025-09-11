import 'dart:convert';
import 'package:http/http.dart' as http;
import 'evaluator_model.dart';

class EvaluatorRemoteDataSource {
  final String baseUrl;

  EvaluatorRemoteDataSource({this.baseUrl = "http://127.0.0.1:8080"});

  Future<void> registerRemote(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse("$baseUrl/evaluator/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to register evaluator: ${response.body}");
    }
  }

  Future<bool> hasAnyEvaluatorAdminRemote() async {
    final response = await http.get(Uri.parse("$baseUrl/evaluator/exists"));
    if (response.statusCode == 200) {
      return response.body == "true";
    }
    throw Exception("Failed to check evaluator existence: ${response.body}");
  }

}