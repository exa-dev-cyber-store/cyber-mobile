import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyber/core/services/crash_reporter_service.dart';
import 'package:cyber/core/utils/app_logger.dart';

class MockLokiHttpAdapter implements HttpClientAdapter {
  int pushCount = 0;
  List<dynamic> sentStreams = [];
  bool simulateFailure = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (simulateFailure) {
      return ResponseBody.fromString(
        'Internal Error',
        500,
        headers: {
          Headers.contentTypeHeader: [Headers.textPlainContentType],
        },
      );
    }

    pushCount++;
    if (options.data != null && options.data is Map<String, dynamic>) {
      sentStreams.addAll(options.data['streams'] ?? []);
    }

    return ResponseBody.fromString(
      '',
      204,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLokiHttpAdapter mockAdapter;

  setUpAll(() {
    dotenv.testLoad(mergeWith: {
      'BASE_URL': 'https://be-apple-store.eka-dev.cloud',
      'LOKI_URL': 'https://loki.eka-dev.cloud/loki/api/v1/push',
    });
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAdapter = MockLokiHttpAdapter();
    CrashReporterService.instance.setHttpClientAdapter(mockAdapter);
  });

  test('CrashReporterService sends error logs to Loki when online', () async {
    final prefs = await SharedPreferences.getInstance();
    final reporter = CrashReporterService.instance;

    await reporter.initialize(preferences: prefs);

    reporter.recordLog('App launched test', level: 'INFO', tag: 'INIT');
    reporter.recordError(
      Exception('Test Exception'),
      StackTrace.current,
      reason: 'Testing crash reporter',
      fatal: true,
      tag: 'CRASH_TEST',
    );

    await Future.delayed(const Duration(milliseconds: 100));

    expect(mockAdapter.pushCount, greaterThan(0));
    final queue = prefs.getStringList('cyber_loki_offline_queue_v1') ?? [];
    expect(queue.isEmpty, isTrue);
  });

  test('CrashReporterService enqueues to local disk when offline/failed and flushes later', () async {
    final prefs = await SharedPreferences.getInstance();
    final reporter = CrashReporterService.instance;

    mockAdapter.simulateFailure = true;
    await reporter.initialize(preferences: prefs);

    reporter.recordLog('Offline log item 1', level: 'WARN', tag: 'NETWORK');
    reporter.recordHttpError(
      method: 'POST',
      path: '/api/checkout',
      statusCode: 502,
      errorMessage: 'Bad Gateway',
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Must be in local storage queue now
    final queue = prefs.getStringList('cyber_loki_offline_queue_v1') ?? [];
    expect(queue.length, equals(2));

    // Now restore connection / server recovery
    mockAdapter.simulateFailure = false;
    await reporter.flushOfflineLogs();

    // After flush, queue must be cleared
    final queueAfter = prefs.getStringList('cyber_loki_offline_queue_v1') ?? [];
    expect(queueAfter.isEmpty, isTrue);
  });

  test('AppLogger seamlessly forwards errors and warnings to Loki', () async {
    final prefs = await SharedPreferences.getInstance();
    await CrashReporterService.instance.initialize(preferences: prefs);

    AppLogger.w('Disk space low warning', 'STORAGE');
    AppLogger.e('Unexpected null pointer', null, StackTrace.current, 'CRITICAL');

    await Future.delayed(const Duration(milliseconds: 100));
    expect(mockAdapter.pushCount, greaterThan(0));
  });
}

