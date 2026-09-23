import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;
    String label;

    final lower = status.trim().toLowerCase();

    if (lower == 'completed' ||
        lower == 'selesai' ||
        lower == 'settlement' ||
        lower == 'success' ||
        lower == 'delivered' ||
        lower == 'paid' ||
        lower == 'lunas') {
      bg = AppColors.successBg;
      fg = AppColors.success;
      border = AppColors.success.withValues(alpha: 0.35);
      icon = Icons.check_circle_rounded;
      if (lower == 'settlement' || lower == 'paid' || lower == 'lunas') {
        label = 'Paid';
      } else if (lower == 'delivered') {
        label = 'Delivered';
      } else if (lower == 'completed' || lower == 'selesai') {
        label = 'Completed';
      } else {
        label = 'Success';
      }
    } else if (lower == 'pending' || lower == 'menunggu') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
      border = AppColors.warning.withValues(alpha: 0.35);
      icon = Icons.access_time_rounded;
      label = 'Pending';
    } else if (lower == 'cancel' ||
        lower == 'cancelled' ||
        lower == 'expire' ||
        lower == 'expired' ||
        lower == 'failed' ||
        lower == 'dibatalkan') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
      border = AppColors.error.withValues(alpha: 0.35);
      icon = Icons.cancel_rounded;
      label = lower.contains('expire') ? 'Expired' : 'Cancelled';
    } else if (lower == 'shipping' ||
        lower == 'dikirim' ||
        lower == 'on_delivery' ||
        lower == 'in_transit') {
      bg = AppColors.infoBg;
      fg = AppColors.info;
      border = AppColors.info.withValues(alpha: 0.35);
      icon = Icons.local_shipping_rounded;
      label = 'Shipped';
    } else if (lower == 'processing' ||
        lower == 'process' ||
        lower == 'diproses' ||
        lower == 'dikemas') {
      bg = AppColors.infoBg;
      fg = AppColors.primary;
      border = AppColors.primary.withValues(alpha: 0.35);
      icon = Icons.sync_rounded;
      label = 'Processing';
    } else {
      bg = AppColors.surfaceTertiary;
      fg = AppColors.textSecondary;
      border = AppColors.border;
      icon = Icons.info_outline_rounded;
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: fg,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
