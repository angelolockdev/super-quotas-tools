/// Safe logger that redacts sensitive tokens from output.
///
/// All debug logging throughout the app MUST go through this
/// utility to ensure no OAuth, JWT, or refresh tokens leak
/// into debug console, crash reports, or log files.
library;

import 'dart:developer' as dev;

class SafeLogger {
  SafeLogger._();

  /// Regex patterns that match common token formats.
  static final List<RegExp> _sensitivePatterns = [
    // JWT tokens (3 base64 segments separated by dots)
    RegExp(r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'),
    // Generic bearer/refresh tokens (long hex/base64 strings)
    RegExp(
      r'(?:token|key|secret|password|refresh)["\s:=]+["\s]*([A-Za-z0-9_\-./+]{20,})',
      caseSensitive: false,
    ),
    // Supabase anon keys
    RegExp(r'eyJhbGciOi[A-Za-z0-9_-]+'),
  ];

  /// Redacts sensitive data from [message] before logging.
  static String _redact(String message) {
    var safe = message;
    for (final pattern in _sensitivePatterns) {
      safe = safe.replaceAll(pattern, '***REDACTED***');
    }
    return safe;
  }

  /// Log an informational message.
  static void info(String message, {String tag = 'CockpitTools'}) {
    dev.log(_redact(message), name: tag);
  }

  /// Log a warning.
  static void warn(String message, {String tag = 'CockpitTools'}) {
    dev.log('⚠️ ${_redact(message)}', name: tag);
  }

  /// Log an error with optional stack trace.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'CockpitTools',
  }) {
    dev.log(
      '❌ ${_redact(message)}',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
