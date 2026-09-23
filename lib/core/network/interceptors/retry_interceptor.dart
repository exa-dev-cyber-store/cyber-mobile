import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Interceptor to automatically retry requests when server responds with 500++ HTTP errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isServerError = statusCode != null && statusCode >= 500;

    // Retry on server errors 500++
    if (isServerError) {
      final requestOptions = err.requestOptions;
      int retryCount = requestOptions.extra['retry_count'] as int? ?? 0;

      if (retryCount < maxRetries) {
        retryCount++;
        requestOptions.extra['retry_count'] = retryCount;

        AppLogger.w(
          'Retrying request: [${requestOptions.method}] ${requestOptions.path} (Attempt $retryCount/$maxRetries) due to HTTP $statusCode',
          'RETRY',
        );

        // Exponential backoff delay
        await Future.delayed(retryDelay * retryCount);

        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.reject(e);
        } catch (e) {
          return handler.reject(
            DioException(requestOptions: requestOptions, error: e),
          );
        }
      }
    }

    return handler.next(err);
  }
}
