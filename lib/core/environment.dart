import '../data/repositories/admin/admin_repository.dart';
import '../data/repositories/admin/online_admin_repository.dart';

enum Environment { local, online }

class AppEnvironment {
  static Environment current = Environment.local;

  static IAdminRepository get adminRepository {
    switch (current) {
      case Environment.local:
        throw UnimplementedError('Initialize LocalAdminRepository with DB');
      case Environment.online:
        return OnlineAdminRepository("http://127.0.0.1:8080"); 
    }
  }
}
