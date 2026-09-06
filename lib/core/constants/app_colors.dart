import 'package:flutter/material.dart';

/// Design tokens inspired by Apple's Human Interface Guidelines.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF000000); // Obsidian / Pure Apple Black
  static const Color primaryLight = Color(0xFF1D1D1F);
  static const Color accent = Color(0xFF0071E3); // Apple Store Blue
  static const Color accentLight = Color(0xFFE8F2FD);

  // Background surfaces
  static const Color background = Color(0xFFF5F5F7); // Apple off-white canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFBFBFD);
  static const Color surfaceTertiary = Color(0xFFF0F0F2);

  // Dark mode surfaces
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceSecondary = Color(0xFF2C2C2E);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderLight = Color(0xFFF2F2F7);
  static const Color borderDark = Color(0xFF38383A);
  static const Color divider = Color(0xFFE5E5EA);

  // Text & Typography
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFF86868B);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF34C759); // Apple Green
  static const Color successBg = Color(0xFFEAF7EE);
  static const Color error = Color(0xFFFF3B30); // Apple Red
  static const Color errorBg = Color(0xFFFEECEB);
  static const Color warning = Color(0xFFFF9500); // Apple Amber/Orange
  static const Color warningBg = Color(0xFFFFF7EB);
  static const Color info = Color(0xFF5856D6); // Apple Indigo
  static const Color infoBg = Color(0xFFEEEEFC);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE5E5EA);
  static const Color shimmerHighlight = Color(0xFFF8F8FA);

  // Shadow
  static const Color cardShadow = Color(0x0A000000);
  static const Color hoverShadow = Color(0x14000000);
}
