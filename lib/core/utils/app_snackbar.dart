import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../network/api_exceptions.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static String? _lastMessage;
  static DateTime? _lastShownTime;
  static DateTime? _lastAnySnackbarTime;
  static const Duration _antiDuplicateDuration = Duration(milliseconds: 2500);
  static const Duration _burstThrottleDuration = Duration(milliseconds: 1200);

  /// General method to show anti-spam toast/snackbar
  static void show({
    required String message,
    String? title,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
    bool force = false,
  }) {
    final cleanMsg = cleanErrorMessage(message);
    if (cleanMsg.trim().isEmpty) return;

    final now = DateTime.now();

    if (!force) {
      // 1. Anti-duplicate guard: suppress identical message within 2.5s
      if (_lastMessage == cleanMsg && _lastShownTime != null) {
        if (now.difference(_lastShownTime!) < _antiDuplicateDuration) {
          return;
        }
      }

      // 2. Burst guard: suppress rapid-fire snackbars within 1.2s (e.g. 5 concurrent API errors)
      if (_lastAnySnackbarTime != null) {
        if (now.difference(_lastAnySnackbarTime!) < _burstThrottleDuration) {
          return;
        }
      }
    }

    // If a snackbar is currently open, close it instantly to prevent sequential queuing
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    _lastMessage = cleanMsg;
    _lastShownTime = now;
    _lastAnySnackbarTime = now;

    Color iconColor;
    Color bgColor;
    Color borderColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case SnackbarType.success:
        iconColor = AppColors.success;
        bgColor = AppColors.surface;
        borderColor = AppColors.success.withValues(alpha: 0.35);
        icon = Icons.check_circle_rounded;
        defaultTitle = 'Berhasil';
        break;
      case SnackbarType.error:
        iconColor = AppColors.error;
        bgColor = AppColors.surface;
        borderColor = AppColors.error.withValues(alpha: 0.35);
        icon = Icons.error_rounded;
        defaultTitle = 'Gagal';
        break;
      case SnackbarType.warning:
        iconColor = AppColors.warning;
        bgColor = AppColors.surface;
        borderColor = AppColors.warning.withValues(alpha: 0.35);
        icon = Icons.warning_rounded;
        defaultTitle = 'Perhatian';
        break;
      case SnackbarType.info:
        iconColor = AppColors.accent;
        bgColor = AppColors.surface;
        borderColor = AppColors.accent.withValues(alpha: 0.35);
        icon = Icons.info_rounded;
        defaultTitle = 'Informasi';
        break;
    }

    final finalTitle = title ?? defaultTitle;

    Get.rawSnackbar(
      titleText: finalTitle.isNotEmpty
          ? Text(
              finalTitle,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
          : null,
      messageText: Text(
        cleanMsg,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          height: 1.35,
        ),
      ),
      icon: Padding(
        padding: const EdgeInsets.only(left: 4, right: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
      snackPosition: position,
      backgroundColor: bgColor,
      borderRadius: AppSpacing.radiusLg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: borderColor,
      borderWidth: 1.2,
      boxShadows: [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      duration: duration,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Shortcut for Success
  static void success(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool force = false,
  }) {
    show(
      message: message,
      title: title,
      type: SnackbarType.success,
      duration: duration,
      force: force,
    );
  }

  /// Shortcut for Error with automatic technical error sanitization
  static void error(
    dynamic errorOrMessage, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool force = false,
  }) {
    show(
      message: cleanErrorMessage(errorOrMessage),
      title: title,
      type: SnackbarType.error,
      duration: duration,
      force: force,
    );
  }

  /// Shortcut for Warning
  static void warning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool force = false,
  }) {
    show(
      message: message,
      title: title,
      type: SnackbarType.warning,
      duration: duration,
      force: force,
    );
  }

  /// Shortcut for Info
  static void info(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    bool force = false,
  }) {
    show(
      message: message,
      title: title,
      type: SnackbarType.info,
      duration: duration,
      force: force,
    );
  }

  /// Sanitizes any exception, Dio error, or raw string into clean, human-friendly Indonesian
  static String cleanErrorMessage(dynamic input) {
    if (input == null) return 'Terjadi kesalahan. Silakan coba lagi.';

    String raw;
    if (input is AppException) {
      raw = input.message;
    } else if (input is DioException) {
      if (input.error is AppException) {
        raw = (input.error as AppException).message;
      } else {
        raw = AppException.fromDioException(input).message;
      }
    } else if (input is String) {
      raw = input;
    } else {
      raw = input.toString();
    }

    // Strip out technical error prefixes from libraries
    raw = raw.replaceAll(RegExp(r'^DioException\s*(\[[^\]]*\])?:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^ClientException:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^SocketException:\s*', caseSensitive: false), '');

    // Map common raw English phrases to friendly Indonesian
    final lower = raw.trim().toLowerCase();
    if (lower.contains('invalid email or password') || lower.contains('invalid credentials')) {
      return 'Email atau kata sandi tidak sesuai. Silakan periksa kembali.';
    }
    if (lower.contains('email already') || lower.contains('user already exists') || lower.contains('duplicate key')) {
      return 'Email ini sudah terdaftar. Silakan masuk atau gunakan email lain.';
    }
    if (lower.contains('connection refused') || lower.contains('failed host lookup') || lower.contains('connection error')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Waktu koneksi habis. Silakan coba beberapa saat lagi.';
    }
    if (lower.contains('jwt expired') || lower.contains('token expired')) {
      return 'Sesi login telah berakhir. Silakan masuk kembali.';
    }
    if (lower.contains('internal server error')) {
      return 'Terjadi kendala pada server kami. Silakan coba beberapa saat lagi.';
    }

    return raw.trim().isEmpty ? 'Terjadi kesalahan yang tidak diketahui.' : raw.trim();
  }
}
