import 'package:flutter/foundation.dart';

class AppLogger {
  /// Logs only in debug mode
  static void log(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] $message');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] ⚠️ WARNING: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] ❌ ERROR: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
