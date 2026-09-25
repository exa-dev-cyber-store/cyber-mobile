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
    if (cleanMsg.trim().isEmpty || Get.testMode) return;

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
        defaultTitle = 'Success';
        break;
      case SnackbarType.error:
        iconColor = AppColors.error;
        bgColor = AppColors.surface;
        borderColor = AppColors.error.withValues(alpha: 0.35);
        icon = Icons.error_rounded;
        defaultTitle = 'Error';
        break;
      case SnackbarType.warning:
        iconColor = AppColors.warning;
        bgColor = AppColors.surface;
        borderColor = AppColors.warning.withValues(alpha: 0.35);
        icon = Icons.warning_rounded;
        defaultTitle = 'Warning';
        break;
      case SnackbarType.info:
        iconColor = AppColors.accent;
        bgColor = AppColors.surface;
        borderColor = AppColors.accent.withValues(alpha: 0.35);
        icon = Icons.info_rounded;
        defaultTitle = 'Information';
        break;
    }

    final finalTitle = title ?? defaultTitle;

    Get.rawSnackbar(
      titleText: const SizedBox.shrink(),
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (finalTitle.isNotEmpty)
                  Text(
                    finalTitle,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (finalTitle.isNotEmpty) const SizedBox(height: 2),
                Text(
                  cleanMsg,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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



  /// Sanitizes any exception, Dio error, or raw string into clean, human-friendly English
  static String cleanErrorMessage(dynamic input) {
    if (input == null) return 'An error occurred. Please try again.';

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
    raw = raw.replaceAll(RegExp(r'^SignInWithApple[A-Za-z0-9_]*(\([^)]*\))?:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^SignInWithAppleAuthorizationException\([^)]*\)', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^PlatformException\s*\(.*?\):\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^DioException\s*(\[[^\]]*\])?:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^ClientException:\s*', caseSensitive: false), '');
    raw = raw.replaceAll(RegExp(r'^SocketException:\s*', caseSensitive: false), '');

    // Map common raw phrases to friendly English
    final lower = raw.trim().toLowerCase();

    // Apple Sign-In error sanitization
    if (lower.contains('signinwithapple') ||
        lower.contains('authenticationservices') ||
        lower.contains('authorizationerror')) {
      if (lower.contains('canceled') ||
          lower.contains('cancelled') ||
          lower.contains('1001') ||
          lower.contains('error 1001')) {
        return ''; // Suppress toast on intentional user cancellation
      }
      return 'Unable to complete Apple Sign-In. Please check your Apple ID settings or try again.';
    }

    if (lower.contains('invalid email or password') || lower.contains('invalid credentials')) {
      return 'Invalid email or password. Please verify your credentials.';
    }
    if (lower.contains('email already') || lower.contains('user already exists') || lower.contains('duplicate key')) {
      return 'This email is already registered. Please sign in or use another email.';
    }
    if (lower.contains('connection refused') || lower.contains('failed host lookup') || lower.contains('connection error')) {
      return 'Cannot connect to the server. Please check your internet connection.';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Connection timed out. Please try again shortly.';
    }
    if (lower.contains('jwt expired') || lower.contains('token expired')) {
      return 'Session expired. Please sign in again.';
    }
    if (lower.contains('internal server error')) {
      return 'A server issue occurred. Please try again later.';
    }

    return raw.trim().isEmpty ? 'An unknown error occurred.' : raw.trim();
  }
}
