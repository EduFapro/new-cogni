import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;

  EvaluatorModel? _cachedUser;

  AuthRepositoryImpl(this._local);

  /// Attempts to log in by verifying email and password
  @override
  Future<EvaluatorModel?> login(String email, String password) async {
    final admin = await _local.getAdminByEmail(email);

    if (admin != null && admin.password == password) {
      await cacheUser(admin);
      return admin;
    }

    return null;
  }

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    final file = await _getUserFile();
    final content = jsonEncode(user.toMap());
    await file.writeAsString(content);
  }

  Future<void> clearCachedUser() async {
    final file = await _getUserFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<EvaluatorModel?> getCachedUser() async {
    try {
      final file = await _getUserFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final map = jsonDecode(content);
      return EvaluatorModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheUser(EvaluatorModel user) async {
    _cachedUser = user;
    }

  @override
  Future<EvaluatorModel?> fetchCurrentUserOrNull() async {
    if (_cachedUser != null) return _cachedUser;

    final user = await _local.getCachedUser();
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    await clearCachedUser();
  }

  Future<File> _getUserFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/current_user.json');
  }

}
