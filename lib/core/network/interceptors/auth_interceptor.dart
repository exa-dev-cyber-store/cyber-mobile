import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../storage/local_storage.dart';
import '../../utils/app_logger.dart';
import '../../utils/app_snackbar.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorageService _storage;

  AuthInterceptor(this._storage);

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.w('Unauthorized (401) detected. Clearing session.');
      _storage.clearAuth();

      // Only redirect if not already on the login/onboarding screen
      final currentRoute = getx.Get.currentRoute;
      if (currentRoute != '/login' && currentRoute != '/onboarding' && currentRoute != '/started') {
        getx.Get.offAllNamed('/login');
        AppSnackbar.warning(
          'Silakan masuk kembali ke akun Anda.',
          title: 'Sesi Berakhir',
        );
      }
    }

    super.onError(err, handler);
  }
}
