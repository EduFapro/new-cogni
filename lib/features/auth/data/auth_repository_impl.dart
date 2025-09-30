import '../../auth/domain/auth_repository.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._local);

  @override
  Future<bool> login(String email, String password) async {
    final admin = await _local.getAdminByEmail(email);
    return admin != null && admin.password == password;
  }
}
