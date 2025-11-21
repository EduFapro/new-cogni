class AppLoggerCli {
  static void info(String message) => print('[INFO] $message');
  static void debug(String message) => print('[DEBUG] $message');
  static void warning(String message) => print('[WARNING] $message');

  static void error(String message, [dynamic error, StackTrace? stack]) {
    print('[ERROR] $message');
    if (error != null) print('Exception: $error');
    if (stack != null) print(stack);
  }

  static void seed(String message) => print('[SEED] $message');
}
