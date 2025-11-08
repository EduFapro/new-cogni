import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../core/logger/app_logger.dart';
import '../../auth/domain/auth_repository.dart';
import '../../evaluator/data/evaluator_model.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;
  EvaluatorModel? _cachedUser;

  AuthRepositoryImpl(this._local);

  @override
  Future<EvaluatorModel?> login(String email, String password) async {
    AppLogger.info('Repository: login called for $email');
    final admin = await _local.getEvaluatorByEmail(email);

    if (admin != null && admin.password == password) {
      AppLogger.info('Password verified for $email');
      await cacheUser(admin);
      return admin;
    }

    AppLogger.warning('Login failed: wrong credentials for $email');
    return null;
  }

  Future<void> saveCurrentUser(EvaluatorModel user) async {
    final file = await _getUserFile();
    final content = jsonEncode(user.toMap());
    await file.writeAsString(content);
    AppLogger.db('Saved current user to file: ${file.path}');
  }

  Future<void> clearCachedUser() async {
    final file = await _getUserFile();
    if (await file.exists()) {
      await file.delete();
      AppLogger.db('Cleared cached user file');
    }
  }

  Future<EvaluatorModel?> getCachedUser() async {
    try {
      final file = await _getUserFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final map = jsonDecode(content);
      AppLogger.db('Loaded cached user from file');
      return EvaluatorModel.fromMap(map);
    } catch (e, s) {
      AppLogger.error('Failed to read cached user file', e, s);
      return null;
    }
  }

  @override
  Future<void> cacheUser(EvaluatorModel user) async {
    _cachedUser = user;
    await saveCurrentUser(user);
    AppLogger.info('User cached in memory and disk');
  }

  @override
  Future<EvaluatorModel?> fetchCurrentUserOrNull() async {
    if (_cachedUser != null) {
      AppLogger.debug('Using in-memory cached user');
      return _cachedUser;
    }
    final user = await _local.getCachedUser();
    _cachedUser = user;
    AppLogger.debug('Fetched cached user from DB: ${user?.email}');
    return user;
  }

  @override
  Future<void> signOut() async {
    AppLogger.info('Signing out current user');
    await clearCachedUser();
  }

  Future<File> _getUserFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/current_user.json');
  }

  @override
  Future<void> saveCurrentUserToDB(EvaluatorModel user) async {
    await _local.saveCurrentUser(user);
  }
  @override
  Future<void> clearCurrentUserFromDB() async {
    await _local.clearCurrentUser();
  }

}
