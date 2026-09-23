import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyber/core/network/interceptors/auth_interceptor.dart';
import 'package:cyber/core/storage/local_storage.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  int refreshCount = 0;
  int orderAttempts = 0;
  int cartAttempts = 0;
  bool shouldRefreshFail = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/auth/refresh')) {
      refreshCount++;
      if (shouldRefreshFail) {
        return ResponseBody.fromString(
          jsonEncode({'success': false, 'message': 'Invalid refresh token'}),
          401,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      }
      await Future.delayed(const Duration(milliseconds: 30));
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': {
            'accessToken': 'fresh-access-token-123',
            'refreshToken': 'rotated-refresh-token-456',
          },
        }),
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }

    final auth = options.headers['Authorization'];
    if (options.path.contains('/api/orders')) orderAttempts++;
    if (options.path.contains('/api/carts')) cartAttempts++;

    if (auth != 'Bearer fresh-access-token-123') {
      return ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'message': 'Token expired',
          'code': 'TOKEN_EXPIRED',
        }),
        401,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'success': true, 'data': [{'id': '101'}]}),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late Dio dio;
  late MockHttpClientAdapter adapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.getInstance();
    await storage.setToken('initial-expired-token');
    await storage.setRefreshToken('valid-refresh-token');
    adapter = MockHttpClientAdapter();

    dio = Dio(BaseOptions(baseUrl: 'https://be-apple-store.eka-dev.cloud'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(storage, dio: dio));
  });

  test('AuthInterceptor injects Bearer token on request', () async {
    expect(storage.token, 'initial-expired-token');
    expect(storage.refreshToken, 'valid-refresh-token');
  });

  test('AuthInterceptor automatically refreshes token on 401 and replays request', () async {
    final response = await dio.get('/api/orders');

    expect(response.statusCode, 200);
    expect(adapter.refreshCount, 1);
    expect(storage.token, 'fresh-access-token-123');
    expect(storage.refreshToken, 'rotated-refresh-token-456');
  });

  test('AuthInterceptor coalesces multiple concurrent 401 requests to single refresh', () async {
    final responses = await Future.wait([
      dio.get('/api/orders'),
      dio.get('/api/carts'),
    ]);

    for (final res in responses) {
      expect(res.statusCode, 200);
    }

    expect(adapter.refreshCount, 1);
    expect(storage.token, 'fresh-access-token-123');
    expect(storage.refreshToken, 'rotated-refresh-token-456');
  });

  test('AuthInterceptor clears storage when refresh token is invalid', () async {
    adapter.shouldRefreshFail = true;

    try {
      await dio.get('/api/orders');
      fail('Expected DioException on failed refresh');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
      expect(storage.token, isNull);
      expect(storage.refreshToken, isNull);
    }
  });
}
