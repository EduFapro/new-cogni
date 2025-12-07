import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static final bool _isRelease = kReleaseMode;
  static File? _logFile;

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

  static Future<void> init() async {
    try {
      debugPrint('🔄 Initializing AppLogger...');
      final docsDir = await getApplicationDocumentsDirectory();
      final sep = Platform.pathSeparator;
      // Use 'NovoCogni' to avoid conflict with legacy 'Cognivoice' folder cleanup
      final logsDir = Directory('${docsDir.path}${sep}NovoCogni${sep}logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final date = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      _logFile = File('${logsDir.path}${sep}log_$date.txt');

      // Force create file if it doesn't exist
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }

      debugPrint('✅ Log file initialized at: ${_logFile!.path}');
      info('=== Application Started ===');
    } catch (e) {
      debugPrint('❌ Failed to initialize log file: $e');
    }
  }

  static void _writeToFile(
    String level,
    String message, [
    dynamic error,
    StackTrace? stack,
  ]) {
    if (_logFile == null) return;

    try {
      final time = DateFormat('HH:mm:ss').format(DateTime.now());
      final logEntry = StringBuffer('[$time] [$level] $message\n');

      if (error != null) {
        logEntry.writeln('Error: $error');
      }
      if (stack != null) {
        logEntry.writeln('Stack trace:\n$stack');
      }

      _logFile!.writeAsStringSync(
        logEntry.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      print('❌ Failed to write to log file: $e');
    }
  }

  static void redirect(
    void Function(String) onLog,
    void Function(String, dynamic, StackTrace?) onError,
  ) {
    _onLog = onLog;
    _onError = onError;
  }

  static void info(String message) {
    _writeToFile('INFO', message);
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.i(message);
  }

  static void debug(String message) {
    _writeToFile('DEBUG', message);
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.d(message);
  }

  static void warning(String message) {
    _writeToFile('WARNING', message);
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    _writeToFile('ERROR', message, error, stack);
    if (_onError != null) {
      _onError!(message, error, stack);
      return;
    }
    if (_isRelease) return;
    _logger.e(message, error: error, stackTrace: stack);
  }

  static void db(String message) {
    _writeToFile('DB', message);
    if (_onLog != null) {
      _onLog!('[DB] $message');
      return;
    }
    if (_isRelease) return;
    _logger.d('[DB] $message');
  }

  static void nav(String message) {
    _writeToFile('NAV', message);
    if (_onLog != null) {
      _onLog!('[NAV] $message');
      return;
    }
    if (_isRelease) return;
    _logger.i('[NAV] $message');
  }

  static void trace(String message) {
    _writeToFile('TRACE', message);
    if (_onLog != null) {
      _onLog!(message);
      return;
    }
    if (_isRelease) return;
    _logger.t(message);
  }

  static void seed(String message) {
    _writeToFile('SEED', message);
    if (_onLog != null) {
      _onLog!('[SEED] $message');
      return;
    }
    if (_isRelease) return;
    _logger.i('[SEED] $message');
  }
}
