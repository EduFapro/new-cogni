import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminRepository {
  final String baseUrl;

  AdminRepository({this.baseUrl = "http://127.0.0.1:8080"});

  Future<void> registerAdmin(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/register"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro: ${response.body}");
    }
  }
}
