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
      printTime: true,
    ),
  );

  static void info(String message) {
    if (_isRelease) return;
    _logger.i(message);
  }

  static void debug(String message) {
    if (_isRelease) return;
    _logger.d(message);
  }

  static void warning(String message) {
    if (_isRelease) return;
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    if (_isRelease) return;
    _logger.e(
      message,
      error: error,
      stackTrace: stack,
    );
  }

  static void db(String message) {
    if (_isRelease) return;
    _logger.d('[DB] $message');
  }

  static void nav(String message) {
    if (_isRelease) return;
    _logger.i('[NAV] $message');
  }

  static void trace(String message) {
    if (_isRelease) return;
    _logger.t(message);
  }
}
