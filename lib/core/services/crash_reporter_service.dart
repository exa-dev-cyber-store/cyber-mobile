import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage.dart';

class CrashReporterService {
  static final CrashReporterService _instance = CrashReporterService._internal();
  static CrashReporterService get instance => _instance;

  CrashReporterService._internal();

  static const String _storageKeyQueue = 'cyber_loki_offline_queue_v1';
  static const int _maxQueueSize = 100;

  final Dio _client = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  SharedPreferences? _preferences;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isFlushing = false;

  /// Allows setting custom HTTP client adapter for mocking/testing
  void setHttpClientAdapter(HttpClientAdapter adapter) {
    _client.httpClientAdapter = adapter;
  }

  String get _lokiUrl {
    try {
      return dotenv.env['LOKI_URL'] ?? 'https://loki.eka-dev.cloud/loki/api/v1/push';
    } catch (_) {
      return 'https://loki.eka-dev.cloud/loki/api/v1/push';
    }
  }

  String get _environment {
    if (kReleaseMode) return 'production';
    if (kProfileMode) return 'profile';
    return 'development';
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Initialize CrashReporter and start offline synchronization
  Future<void> initialize({SharedPreferences? preferences}) async {
    try {
      _preferences = preferences ?? await SharedPreferences.getInstance();

      // Listen for connectivity restoration to flush offline logs
      _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
        final isOnline = results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
        if (isOnline) {
          flushOfflineLogs();
        }
      });

      // Attempt initial flush on app start
      flushOfflineLogs();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ CrashReporter initialization warning: $e');
      }
    }
  }

  /// Record Flutter Framework Fatal Errors (Widget / Render Errors)
  void recordFlutterFatalError(FlutterErrorDetails details) {
    recordError(
      details.exceptionAsString(),
      details.stack,
      reason: details.context?.toString() ?? 'Flutter Framework Error',
      fatal: true,
      tag: 'FLUTTER_FATAL',
    );
  }

  /// Record Asynchronous or Catch-block Exceptions
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    String tag = 'ERROR',
    Map<String, dynamic>? customData,
  }) {
    final payload = {
      'message': error.toString(),
      'reason': reason ?? '',
      'stackTrace': stackTrace?.toString() ?? '',
      'fatal': fatal,
      'tag': tag,
      'timestamp': DateTime.now().toIso8601String(),
      if (customData != null) 'data': customData,
    };

    _dispatch(
      level: fatal ? 'CRITICAL' : 'ERROR',
      tag: tag,
      body: payload,
    );
  }

  /// Record General Informational / Warning Logs
  void recordLog(
    String message, {
    String level = 'INFO',
    String tag = 'APP',
    Map<String, dynamic>? extra,
  }) {
    final payload = {
      'message': message,
      'tag': tag,
      'timestamp': DateTime.now().toIso8601String(),
      if (extra != null) 'extra': extra,
    };

    _dispatch(
      level: level.toUpperCase(),
      tag: tag,
      body: payload,
    );
  }

  /// Record Network & API Failures (Dio Interceptor)
  void recordHttpError({
    required String method,
    required String path,
    int? statusCode,
    String? errorMessage,
    dynamic responseBody,
    Duration? duration,
  }) {
    final payload = {
      'http_method': method,
      'path': path,
      'status_code': statusCode ?? 0,
      'error': errorMessage ?? '',
      'duration_ms': duration?.inMilliseconds,
      'response': responseBody?.toString() ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _dispatch(
      level: (statusCode != null && statusCode >= 500) ? 'ERROR' : 'WARN',
      tag: 'HTTP_API',
      body: payload,
    );
  }

  /// Internal Dispatcher: Sends immediately or enqueues offline
  void _dispatch({
    required String level,
    required String tag,
    required Map<String, dynamic> body,
  }) {
    // Enrich with session user ID if available
    String? userId;
    try {
      userId = LocalStorageService.instance.userId;
    } catch (_) {}

    final logEntry = {
      'timestamp_ns': (DateTime.now().microsecondsSinceEpoch * 1000).toString(),
      'level': level,
      'tag': tag,
      'user_id': (userId != null && userId.isNotEmpty) ? userId : 'anonymous',
      'platform': _platformName,
      'environment': _environment,
      'app': 'cyber-mobile',
      'body': jsonEncode(body),
    };

    // Try direct send asynchronously
    _sendEntries([logEntry]).catchError((_) {
      _enqueueOffline(logEntry);
    });
  }

  /// Enqueue to local disk storage when offline
  Future<void> _enqueueOffline(Map<String, dynamic> entry) async {
    try {
      final prefs = _preferences ?? await SharedPreferences.getInstance();
      final currentQueue = prefs.getStringList(_storageKeyQueue) ?? [];

      // Cap queue size
      if (currentQueue.length >= _maxQueueSize) {
        currentQueue.removeAt(0); // Evict oldest
      }

      currentQueue.add(jsonEncode(entry));
      await prefs.setStringList(_storageKeyQueue, currentQueue);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ Failed to enqueue offline crash log: $e');
      }
    }
  }

  /// Flush queued offline logs to Loki
  Future<void> flushOfflineLogs() async {
    if (_isFlushing) return;
    _isFlushing = true;

    try {
      final prefs = _preferences ?? await SharedPreferences.getInstance();
      final currentQueue = prefs.getStringList(_storageKeyQueue) ?? [];

      if (currentQueue.isEmpty) {
        _isFlushing = false;
        return;
      }

      final List<Map<String, dynamic>> parsedEntries = [];
      for (final raw in currentQueue) {
        try {
          parsedEntries.add(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {}
      }

      if (parsedEntries.isNotEmpty) {
        await _sendEntries(parsedEntries);
        // Clear queue on successful flush
        await prefs.remove(_storageKeyQueue);
        if (kDebugMode) {
          // ignore: avoid_print
          print('✅ Flushed ${parsedEntries.length} offline log(s) to Loki');
        }
      }
    } catch (_) {
      // Retain logs in queue for next retry
    } finally {
      _isFlushing = false;
    }
  }

  /// Batch and POST to Loki Ingress API
  Future<void> _sendEntries(List<Map<String, dynamic>> entries) async {
    if (entries.isEmpty) return;

    // Group entries by stream labels
    final Map<String, List<List<String>>> streamsMap = {};
    final Map<String, Map<String, String>> labelMap = {};

    for (final item in entries) {
      final app = item['app']?.toString() ?? 'cyber-mobile';
      final level = item['level']?.toString() ?? 'INFO';
      final platform = item['platform']?.toString() ?? _platformName;
      final env = item['environment']?.toString() ?? _environment;
      final tag = item['tag']?.toString() ?? 'APP';
      final userId = item['user_id']?.toString() ?? 'anonymous';

      final streamKey = '$app-$level-$platform-$env-$tag';

      if (!streamsMap.containsKey(streamKey)) {
        streamsMap[streamKey] = [];
        labelMap[streamKey] = {
          'app': app,
          'level': level,
          'platform': platform,
          'environment': env,
          'tag': tag,
          'user_id': userId,
        };
      }

      final ts = item['timestamp_ns']?.toString() ??
          (DateTime.now().microsecondsSinceEpoch * 1000).toString();
      final body = item['body']?.toString() ?? '';

      streamsMap[streamKey]!.add([ts, body]);
    }

    final List<Map<String, dynamic>> streamsList = [];
    for (final entry in streamsMap.entries) {
      streamsList.add({
        'stream': labelMap[entry.key],
        'values': entry.value,
      });
    }

    final payload = {'streams': streamsList};

    final response = await _client.post(
      _lokiUrl,
      data: payload,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Loki push returned status ${response.statusCode}');
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
