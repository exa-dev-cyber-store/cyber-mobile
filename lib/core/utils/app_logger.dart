import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../services/crash_reporter_service.dart';

enum LogLevel { debug, info, warning, error, success }

class AppLogger {
  AppLogger._();

  // ANSI color codes for terminal
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _cyan = '\x1B[36m';

  static void d(String message, [String tag = 'DEBUG']) {
    _log(message, tag: tag, level: LogLevel.debug);
  }

  static void i(String message, [String tag = 'INFO']) {
    _log(message, tag: tag, level: LogLevel.info);
  }

  static void s(String message, [String tag = 'SUCCESS']) {
    _log(message, tag: tag, level: LogLevel.success);
  }

  static void w(String message, [String tag = 'WARN']) {
    _log(message, tag: tag, level: LogLevel.warning);
    CrashReporterService.instance.recordLog(message, level: 'WARN', tag: tag);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace, String tag = 'ERROR']) {
    _log(message, tag: tag, level: LogLevel.error, error: error, stackTrace: stackTrace);
    CrashReporterService.instance.recordError(
      error ?? message,
      stackTrace,
      reason: message,
      tag: tag,
    );
  }

  static void _log(
    String message, {
    required String tag,
    required LogLevel level,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    String prefix;
    String color;

    switch (level) {
      case LogLevel.debug:
        prefix = '🔍 [$tag]';
        color = _cyan;
        break;
      case LogLevel.info:
        prefix = 'ℹ️ [$tag]';
        color = _blue;
        break;
      case LogLevel.success:
        prefix = '✅ [$tag]';
        color = _green;
        break;
      case LogLevel.warning:
        prefix = '⚠️ [$tag]';
        color = _yellow;
        break;
      case LogLevel.error:
        prefix = '❌ [$tag]';
        color = _red;
        break;
    }

    final formatted = '$color$prefix ($timestamp): $message$_reset';
    developer.log(formatted, name: 'CyberApp', error: error, stackTrace: stackTrace);
  }
}
