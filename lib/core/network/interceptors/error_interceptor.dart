import 'package:dio/dio.dart';
import '../api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Wrap DioException into typed AppException
    final appException = AppException.fromDioException(err);

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
