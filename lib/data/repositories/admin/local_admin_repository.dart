import 'package:sqflite/sqflite.dart';

import 'admin_repository.dart';

class LocalAdminRepository implements IAdminRepository {
  final Database db;

  LocalAdminRepository(this.db);

  @override
  Future<void> registerAdmin(Map<String, dynamic> adminData) async {
    await db.insert('admins', adminData);
  }

  @override
  Future<List<Map<String, dynamic>>> getAdmins() async {
    return await db.query('admins');
  }

  @override
  Future<void> deleteAdmin(String id) async {
    await db.delete('admins', where: 'id = ?', whereArgs: [id]);
  }
}
