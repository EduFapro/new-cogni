abstract class IAdminRepository {
  Future<void> registerAdmin(Map<String, dynamic> adminData);
  Future<List<Map<String, dynamic>>> getAdmins();
  Future<void> deleteAdmin(String id);
}
