import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;

  factory AppException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkTimeoutException('Koneksi ke server timeout. Silakan coba lagi.');
      case DioExceptionType.sendTimeout:
        return NetworkTimeoutException('Waktu pengiriman data habis. Silakan coba lagi.');
      case DioExceptionType.receiveTimeout:
        return NetworkTimeoutException('Waktu penerimaan respons server habis.');
      case DioExceptionType.badCertificate:
        return SecurityException('Sertifikat keamanan server tidak valid.');
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;

        String message = 'Terjadi kesalahan pada server ($statusCode)';
        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          } else if (responseData['error'] != null) {
            message = responseData['error'].toString();
          }
        }

        // Clean up common English backend responses to clear Indonesian messages
        final lower = message.trim().toLowerCase();
        if (lower.contains('invalid email or password') || lower.contains('invalid credentials')) {
          message = 'Email atau kata sandi tidak sesuai. Silakan periksa kembali.';
        } else if (lower.contains('email already') || lower.contains('user already exists') || lower.contains('duplicate key')) {
          message = 'Email ini sudah terdaftar. Silakan masuk atau gunakan email lain.';
        } else if (lower.contains('jwt expired') || lower.contains('token expired')) {
          message = 'Sesi login telah berakhir. Silakan masuk kembali.';
        }

        switch (statusCode) {
          case 400:
            return BadRequestException(message, details: responseData);
          case 401:
            return UnauthorizedException(message);
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 409:
            return ConflictException(message);
          case 500:
          case 502:
          case 503:
            return ServerException(message, statusCode: statusCode);
          default:
            return AppException(message, statusCode: statusCode, details: responseData);
        }
      case DioExceptionType.cancel:
        return RequestCancelledException('Permintaan dibatalkan.');
      case DioExceptionType.connectionError:
        return NoInternetException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      case DioExceptionType.unknown:
      default:
        final rawMsg = dioException.message ?? '';
        if (rawMsg.contains('SocketException') || rawMsg.contains('Connection refused') || rawMsg.contains('Network is unreachable')) {
          return NoInternetException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
        }
        return AppException('Terjadi kendala jaringan. Silakan periksa koneksi internet Anda.');
    }
  }
}

class NetworkTimeoutException extends AppException {
  NetworkTimeoutException(super.message);
}

class NoInternetException extends AppException {
  NoInternetException(super.message);
}

class SecurityException extends AppException {
  SecurityException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends AppException {
  NotFoundException(super.message) : super(statusCode: 404);
}

class BadRequestException extends AppException {
  BadRequestException(super.message, {super.details}) : super(statusCode: 400);
}

class ConflictException extends AppException {
  ConflictException(super.message) : super(statusCode: 409);
}

class ServerException extends AppException {
  ServerException(super.message, {int? statusCode}) : super(statusCode: statusCode ?? 500);
}

class RequestCancelledException extends AppException {
  RequestCancelledException(super.message);
}
