import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PrettyLoggingInterceptor extends Interceptor {
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _cyan = '\x1B[36m';
  static const String _magenta = '\x1B[35m';

  final Map<String, DateTime> _requestTimestamps = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final requestId = '${options.method}_${options.uri}';
      _requestTimestamps[requestId] = DateTime.now();

      final buffer = StringBuffer();
      buffer.writeln('$_cyan┌── [DIO REQUEST] ──────────────────────────────────────────$_reset');
      buffer.writeln('$_cyan│ 🌐 ${options.method} ${options.uri}$_reset');

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('$_cyan│ 🔍 Query: ${jsonEncode(options.queryParameters)}$_reset');
      }

      final safeHeaders = Map<String, dynamic>.from(options.headers);
      if (safeHeaders.containsKey('Authorization')) {
        final auth = safeHeaders['Authorization'].toString();
        if (auth.length > 20) {
          safeHeaders['Authorization'] = '${auth.substring(0, 15)}...[PROTECTED]';
        }
      }
      buffer.writeln('$_cyan│ 📋 Headers: ${jsonEncode(safeHeaders)}$_reset');

      if (options.data != null) {
        final bodyStr = options.data is FormData ? '[FormData]' : jsonEncode(options.data);
        buffer.writeln('$_cyan│ 📦 Body: $bodyStr$_reset');
      }

      buffer.writeln('$_cyan└───────────────────────────────────────────────────────────$_reset');
      debugPrint(buffer.toString());
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final requestId = '${response.requestOptions.method}_${response.requestOptions.uri}';
      final start = _requestTimestamps.remove(requestId);
      final duration = start != null ? '${DateTime.now().difference(start).inMilliseconds}ms' : '-';

      final statusCode = response.statusCode ?? 200;
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '🟢' : '🟡';
      final color = statusCode >= 200 && statusCode < 300 ? _green : _yellow;

      final buffer = StringBuffer();
      buffer.writeln('$color┌── [DIO RESPONSE] ─────────────────────────────────────────$_reset');
      buffer.writeln('$color│ $statusEmoji $statusCode ${response.statusMessage ?? 'OK'} [$duration]$_reset');
      buffer.writeln('$color│ 🌐 ${response.requestOptions.method} ${response.requestOptions.path}$_reset');

      if (response.data != null) {
        String dataStr;
        try {
          dataStr = jsonEncode(response.data);
        } catch (_) {
          dataStr = response.data.toString();
        }

        if (dataStr.length > 500) {
          dataStr = '${dataStr.substring(0, 500)}... (truncated ${dataStr.length} chars)';
        }
        buffer.writeln('$color│ 📦 Data: $dataStr$_reset');
      }

      buffer.writeln('$color└───────────────────────────────────────────────────────────$_reset');
      debugPrint(buffer.toString());
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final requestId = '${err.requestOptions.method}_${err.requestOptions.uri}';
      final start = _requestTimestamps.remove(requestId);
      final duration = start != null ? '${DateTime.now().difference(start).inMilliseconds}ms' : '-';

      final statusCode = err.response?.statusCode ?? 0;
      final buffer = StringBuffer();
      buffer.writeln('$_red┌── [DIO ERROR] ────────────────────────────────────────────$_reset');
      buffer.writeln('$_red│ 🔴 Status: $statusCode | Type: ${err.type} [$duration]$_reset');
      buffer.writeln('$_red│ 🌐 ${err.requestOptions.method} ${err.requestOptions.uri}$_reset');
      buffer.writeln('$_red│ 💬 Message: ${err.message}$_reset');

      if (err.response?.data != null) {
        buffer.writeln('$_magenta│ 📦 Error Body: ${jsonEncode(err.response?.data)}$_reset');
      }

      buffer.writeln('$_red└───────────────────────────────────────────────────────────$_reset');
      debugPrint(buffer.toString());
    }

    super.onError(err, handler);
  }
}
