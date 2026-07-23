import 'package:logger/logger.dart';

/// Application logger wrapper
/// 
/// Provides a consistent logging interface throughout the app.
/// Uses the 'logger' package with pretty printing for development.
/// 
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error, stackTrace);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );
  
  /// Verbose logging (most detailed)
  static void v(dynamic message) => _logger.t(message);
  
  /// Debug logging (detailed info for debugging)
  static void d(dynamic message) => _logger.d(message);
  
  /// Info logging (general information)
  static void i(dynamic message) => _logger.i(message);
  
  /// Warning logging (potential issues)
  static void w(dynamic message) => _logger.w(message);
  
  /// Error logging (errors that don't crash the app)
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) => 
    _logger.e(message, error: error, stackTrace: stackTrace);
  
  /// Fatal logging (errors that crash the app)
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) => 
    _logger.f(message, error: error, stackTrace: stackTrace);
  
  /// Log with custom level
  static void log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) =>
    _logger.log(level, message, error: error, stackTrace: stackTrace);
}