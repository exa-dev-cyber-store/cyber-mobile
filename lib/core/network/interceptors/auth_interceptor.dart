import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../constants/api_endpoints.dart';
import '../../storage/local_storage.dart';
import '../../utils/app_logger.dart';
import '../../utils/app_snackbar.dart';

/// Interceptor that handles Bearer token injection, automatic token refresh
/// on 401 Unauthorized responses, token rotation, and safe redirection to login.
class AuthInterceptor extends QueuedInterceptor {
  final LocalStorageService _storage;
  final Dio dio;

  AuthInterceptor(this._storage, {required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Attach token if present and not already specified
    final token = _storage.token;
    if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Default JSON headers
    options.headers['Accept'] = 'application/json';
    if (!options.headers.containsKey('Content-Type') && options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Check if error is 401 Unauthorized
    if (statusCode == 401) {
      // Exclude authentication and registration endpoints to prevent infinite refresh loops
      final isAuthEndpoint = path.contains(ApiEndpoints.login) ||
          path.contains(ApiEndpoints.register) ||
          path.contains(ApiEndpoints.googleLogin) ||
          path.contains(ApiEndpoints.appleAuth) ||
          path.contains(ApiEndpoints.refreshToken) ||
          path.contains(ApiEndpoints.logout);

      if (!isAuthEndpoint) {
        final currentToken = _storage.token;
        final requestAuthHeader = err.requestOptions.headers['Authorization'] as String?;

        // 1. Check if token was ALREADY refreshed while this request was queued
        if (currentToken != null &&
            currentToken.isNotEmpty &&
            requestAuthHeader != null &&
            requestAuthHeader != 'Bearer $currentToken') {
          AppLogger.i(
            'Token was already refreshed by a prior request. Retrying $path with updated token.',
            'AUTH',
          );
          try {
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $currentToken';
            final retryDio = _createRetryDio();
            final retryResponse = await retryDio.fetch(opts);
            return handler.resolve(retryResponse);
          } catch (retryError) {
            if (retryError is DioException) {
              return handler.next(retryError);
            }
            return handler.next(err);
          }
        }

        // 2. Perform refresh if refresh token is available
        final refreshToken = _storage.refreshToken;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          AppLogger.i('Unauthorized (401) on $path. Refreshing access token...', 'AUTH');
          final refreshed = await _refreshAccessToken(refreshToken);
          if (refreshed) {
            final newToken = _storage.token;
            try {
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              final retryDio = _createRetryDio();
              final retryResponse = await retryDio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (retryError) {
              if (retryError is DioException) {
                return handler.next(retryError);
              }
              return handler.next(err);
            }
          }
        }

        // 3. Refresh failed or no refresh token: clear session and redirect to login
        AppLogger.w('Token refresh failed or refresh token absent. Clearing session.', 'AUTH');
        await _storage.clearAuth();
        _redirectToLogin();
      }
    }

    super.onError(err, handler);
  }

  /// Create a clean Dio instance sharing the adapter to replay requests without interceptor recursion
  Dio _createRetryDio() {
    final retryDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
        responseType: dio.options.responseType,
      ),
    );
    retryDio.httpClientAdapter = dio.httpClientAdapter;
    return retryDio;
  }

  /// Call backend refresh endpoint to rotate refresh token and get a new access token
  Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      refreshDio.httpClientAdapter = dio.httpClientAdapter;

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        final data = (resData is Map && resData['data'] != null)
            ? resData['data']
            : resData;

        if (data is Map) {
          final newAccessToken = data['accessToken'] ?? data['token'];
          final newRefreshToken = data['refreshToken'];

          if (newAccessToken != null) {
            await _storage.setToken(newAccessToken.toString());
            if (newRefreshToken != null) {
              await _storage.setRefreshToken(newRefreshToken.toString());
            }
            AppLogger.s('Token refreshed successfully.', 'AUTH');
            return true;
          }
        }
      }
    } catch (e, stack) {
      AppLogger.e('Failed to refresh token: $e', e, stack, 'AUTH');
    }
    return false;
  }

  void _redirectToLogin() {
    try {
      final currentRoute = getx.Get.currentRoute;
      if (currentRoute != '/login' &&
          currentRoute != '/register' &&
          currentRoute != '/onboarding' &&
          currentRoute != '/started') {
        getx.Get.offAllNamed('/login');
        AppSnackbar.warning(
          'Your session has expired. Please sign in again.',
          title: 'Session Expired',
        );
      }
    } catch (e) {
      AppLogger.w('Failed to redirect to login: $e', 'AUTH');
    }
  }
}
