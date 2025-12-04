import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final bool _isRelease = kReleaseMode;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void Function(String message)? _onLog;
  static void Function(String message, dynamic error, StackTrace? stack)?
  _onError;

  static void redirect(
    void Function(String) onLog,
    void Function(String, dynamic, StackTrace?) onError,
  ) {
    _onLog = onLog;
    _onError = onError;
  }

  static void info(String message) {
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.i(message);
  }

  static void debug(String message) {
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.d(message);
  }

  static void warning(String message) {
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    if (_onError != null) {
      _onError!(message, error, stack);
      return;
    }
    if (_isRelease) return;
    _logger.e(message, error: error, stackTrace: stack);
  }

  static void db(String message) {
    if (_onLog != null) {
      _onLog!('[DB] $message');
      return;
    }
    if (_isRelease) return;
    _logger.d('[DB] $message');
  }

  static void nav(String message) {
    if (_onLog != null) {
      _onLog!('[NAV] $message');
      return;
    }
    if (_isRelease) return;
    _logger.i('[NAV] $message');
  }

  static void trace(String message) {
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.t(message);
  }

  static void seed(String message) {
    if (_onLog != null) {
      _onLog!('[SEED] $message');
      return;
    }
    if (_isRelease) return;
    _logger.i('[SEED] $message');
  }
}
