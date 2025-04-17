import '../../preload_google_ads.dart';

/// A simple logger utility for debugging purposes.
/// Logs messages only when the app is running in debug mode.
class AppLogger {
  /// Logs a general message with a timestamp.
  /// Only prints in debug mode.
  static void log(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] $message');
    }
  }

  /// Logs a warning message with a timestamp and ⚠️ symbol.
  /// Only prints in debug mode.
  static void warn(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] ⚠️ WARNING: $message');
    }
  }

  /// Logs an error message with a timestamp and ❌ symbol.
  /// Only prints in debug mode.
  static void error(String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String();
      print('[$time] ❌ ERROR: $message');
    }
  }

  /// Logs a raw debug message without a timestamp.
  /// Useful for quick inline checks. Only prints in debug mode.
  static void debug(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
