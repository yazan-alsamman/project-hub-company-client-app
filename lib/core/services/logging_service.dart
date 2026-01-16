import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  File? _logFile;
  bool _isInitialized = false;

  // Set to false in production to disable console output
  static const bool _enableConsoleOutput = kDebugMode;

  // Maximum log file size (5MB)
  static const int _maxLogFileSize = 5 * 1024 * 1024;

  // Logging directory and file names
  static const String _loggingFolderName = 'logging';
  static const String _logFileName = 'app_audit.log';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Directory logDirectory;

      // Check if we're on desktop (Windows, macOS, Linux) in debug mode
      // Use project directory for easier access during development
      if (kDebugMode && _isDesktopPlatform()) {
        final projectPath = Directory.current.path;
        // Verify the path is valid and writable (not root directory)
        if (projectPath.length > 1 && !projectPath.startsWith('//')) {
          logDirectory = Directory('$projectPath/$_loggingFolderName');
        } else {
          // Fallback to application documents directory
          logDirectory = await _getAppDocumentsLogDirectory();
        }
      } else {
        // For mobile platforms, use application documents directory
        logDirectory = await _getAppDocumentsLogDirectory();
      }

      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      _logFile = File('${logDirectory.path}/$_logFileName');

      // Rotate log file if too large
      if (await _logFile!.exists()) {
        final fileSize = await _logFile!.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFile(logDirectory.path);
        }
      }

      _isInitialized = true;
      await _log(LogLevel.info, 'SYSTEM', 'Logging service initialized - Log file: ${_logFile!.path}');
    } catch (e) {
      if (_enableConsoleOutput) {
        debugPrint('Failed to initialize logging service: $e');
      }
      // Try fallback initialization
      await _initializeFallback();
    }
  }

  bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  Future<Directory> _getAppDocumentsLogDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return Directory('${documentsDir.path}/$_loggingFolderName');
  }

  Future<void> _initializeFallback() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${documentsDir.path}/$_loggingFolderName');

      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      _logFile = File('${logDirectory.path}/$_logFileName');
      _isInitialized = true;

      if (_enableConsoleOutput) {
        debugPrint('Logging service initialized (fallback) - Log file: ${_logFile!.path}');
      }
    } catch (e) {
      if (_enableConsoleOutput) {
        debugPrint('Fallback logging initialization also failed: $e');
      }
    }
  }

  Future<void> _rotateLogFile(String logDirectoryPath) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final archiveFile = File('$logDirectoryPath/app_audit_$timestamp.log');
      await _logFile!.rename(archiveFile.path);
      _logFile = File('$logDirectoryPath/$_logFileName');
    } catch (e) {
      if (_enableConsoleOutput) {
        debugPrint('Failed to rotate log file: $e');
      }
    }
  }

  Future<void> _log(LogLevel level, String tag, String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final logEntry = '[$timestamp] [$levelStr] [$tag] $message\n';

    if (_enableConsoleOutput) {
      debugPrint(logEntry.trim());
    }

    if (_logFile != null && _isInitialized) {
      try {
        await _logFile!.writeAsString(logEntry, mode: FileMode.append, flush: true);
      } catch (e) {
        if (_enableConsoleOutput) {
          debugPrint('Failed to write to log file: $e');
        }
      }
    }
  }

  // API Request logging
  Future<void> logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    await initialize();

    final sanitizedHeaders = _sanitizeHeaders(headers);
    final sanitizedBody = _sanitizeBody(body);

    final message = '''
REQUEST: $method $url
Headers: $sanitizedHeaders
Body: $sanitizedBody''';

    await _log(LogLevel.info, 'API_REQUEST', message);
  }

  // API Response logging
  Future<void> logResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic body,
    Duration? duration,
  }) async {
    await initialize();

    final sanitizedBody = _sanitizeResponseBody(body);
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';

    final level = statusCode >= 400 ? LogLevel.error : LogLevel.info;

    final message = '''
RESPONSE: $method $url$durationStr
Status: $statusCode
Body: $sanitizedBody''';

    await _log(level, 'API_RESPONSE', message);
  }

  // Error logging
  Future<void> logError({
    required String tag,
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) async {
    await initialize();

    final errorMessage = '''
$message
Error: $error
StackTrace: ${stackTrace?.toString().split('\n').take(5).join('\n') ?? 'N/A'}''';

    await _log(LogLevel.error, tag, errorMessage);
  }

  // Info logging
  Future<void> logInfo(String tag, String message) async {
    await initialize();
    await _log(LogLevel.info, tag, message);
  }

  // Warning logging
  Future<void> logWarning(String tag, String message) async {
    await initialize();
    await _log(LogLevel.warning, tag, message);
  }

  // Debug logging (only in debug mode)
  Future<void> logDebug(String tag, String message) async {
    if (!kDebugMode) return;
    await initialize();
    await _log(LogLevel.debug, tag, message);
  }

  // Auth event logging
  Future<void> logAuthEvent({
    required String event,
    String? userId,
    String? role,
    bool success = true,
  }) async {
    await initialize();

    final status = success ? 'SUCCESS' : 'FAILED';
    final message = 'Event: $event | Status: $status | UserId: ${userId ?? 'N/A'} | Role: ${role ?? 'N/A'}';

    await _log(success ? LogLevel.info : LogLevel.warning, 'AUTH', message);
  }

  // Sanitize headers to remove sensitive data
  Map<String, String> _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};

    final sanitized = Map<String, String>.from(headers);

    if (sanitized.containsKey('Authorization')) {
      final token = sanitized['Authorization'] ?? '';
      if (token.length > 20) {
        sanitized['Authorization'] = '${token.substring(0, 15)}...[REDACTED]';
      }
    }

    return sanitized;
  }

  // Sanitize request body to remove sensitive data
  String _sanitizeBody(dynamic body) {
    if (body == null) return 'null';

    if (body is Map) {
      final sanitized = Map<String, dynamic>.from(body);

      // Remove sensitive fields
      const sensitiveFields = ['password', 'token', 'refreshToken', 'refresh_token', 'secret', 'apiKey'];
      for (final field in sensitiveFields) {
        if (sanitized.containsKey(field)) {
          sanitized[field] = '[REDACTED]';
        }
      }

      return sanitized.toString();
    }

    return body.toString();
  }

  // Sanitize response body
  String _sanitizeResponseBody(dynamic body) {
    if (body == null) return 'null';

    String bodyStr = body.toString();

    // Truncate very long responses
    if (bodyStr.length > 500) {
      bodyStr = '${bodyStr.substring(0, 500)}...[TRUNCATED]';
    }

    // Redact tokens in response
    bodyStr = bodyStr.replaceAllMapped(
      RegExp(r'(token|refreshToken|refresh_token):\s*[^\s,}]+'),
      (match) => '${match.group(1)}: [REDACTED]',
    );

    return bodyStr;
  }

  // Get log file path for debugging/export
  Future<String?> getLogFilePath() async {
    await initialize();
    return _logFile?.path;
  }

  // Clear logs
  Future<void> clearLogs() async {
    await initialize();
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
      await _log(LogLevel.info, 'SYSTEM', 'Logs cleared');
    }
  }

  // Read logs (for display in app if needed)
  Future<String> readLogs({int lines = 100}) async {
    await initialize();
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }

    try {
      final content = await _logFile!.readAsString();
      final allLines = content.split('\n');
      final lastLines = allLines.length > lines
          ? allLines.sublist(allLines.length - lines)
          : allLines;
      return lastLines.join('\n');
    } catch (e) {
      return 'Failed to read logs: $e';
    }
  }
}
