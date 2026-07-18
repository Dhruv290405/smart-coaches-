import 'dart:developer' as dev;

enum LogLevel { debug, info, warn, error }

class Logger {
  final String tag;
  static LogLevel _globalLevel = LogLevel.debug;

  Logger(this.tag);

  static void setLevel(LogLevel level) {
    _globalLevel = level;
  }

  void debug(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.debug, 'DEBUG', message, error, stack);
  }

  void info(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.info, 'INFO', message, error, stack);
  }

  void warn(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.warn, 'WARN', message, error, stack);
  }

  void error(String message, [Object? error, StackTrace? stack]) {
    _log(LogLevel.error, 'ERROR', message, error, stack);
  }

  void _log(LogLevel level, String label, String message, Object? error, StackTrace? stack) {
    if (level.index < _globalLevel.index) return;
    final prefix = '[${_time()}] [$label] [$tag]';
    final msg = error != null ? '$message | $error' : message;
    dev.log('$prefix $msg', stackTrace: stack);
  }

  static String _time() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
  }
}
