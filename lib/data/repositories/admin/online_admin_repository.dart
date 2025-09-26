import 'dart:convert';
import 'package:http/http.dart' as http;

import 'admin_repository.dart';

class OnlineAdminRepository implements IAdminRepository {
  final String baseUrl;

  OnlineAdminRepository(this.baseUrl);

  @override
  Future<void> registerAdmin(Map<String, dynamic> adminData) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(adminData),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to register admin: ${res.body}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAdmins() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/all'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load admins: ${res.body}');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  @override
  Future<void> deleteAdmin(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete admin: ${res.body}');
    }
  }
}
