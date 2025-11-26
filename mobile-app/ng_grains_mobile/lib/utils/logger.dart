import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debug(String message) {
    // Use debugPrint which is safe for large messages and avoids lint 'avoid_print'
    debugPrint('DEBUG: $message');
  }

  static void info(String message) {
    debugPrint('INFO: $message');
  }

  static void error(String message, [dynamic error]) {
    debugPrint('ERROR: $message${error != null ? ' - $error' : ''}');
  }
}