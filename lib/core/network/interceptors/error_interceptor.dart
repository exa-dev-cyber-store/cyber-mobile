import 'package:dio/dio.dart';
import '../../services/crash_reporter_service.dart';
import '../api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Wrap DioException into typed AppException
    final appException = AppException.fromDioException(err);

    // Record HTTP error to Loki
    try {
      CrashReporterService.instance.recordHttpError(
        method: err.requestOptions.method,
        path: err.requestOptions.path,
        statusCode: err.response?.statusCode,
        errorMessage: appException.message,
        responseBody: err.response?.data,
      );
    } catch (_) {}

    final transformedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appException,
      message: appException.message,
    );

    super.onError(transformedError, handler);
  }
}
