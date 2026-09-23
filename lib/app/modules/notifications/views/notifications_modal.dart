import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/notification_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/notifications_controller.dart';

class NotificationsModal extends StatelessWidget {
  const NotificationsModal({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(
      const NotificationsModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Obx(() {
                      final count = controller.unreadCount.value;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: AppSpacing.roundedPill,
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '$count new',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_full_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(Routes.NOTIFICATIONS);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // List
          Expanded(
            child: Obx(() {
              if (!controller.isAuthenticated) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Sign In Required', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign in to see your notifications and order status.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none_outlined, size: 56, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.lg),
                        Text('No Notifications', style: AppTextStyles.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Shipping alerts and promo vouchers will appear here.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: controller.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = controller.notifications[index];
                  return _buildModalCard(context, item, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModalCard(BuildContext context, NotificationModel item, NotificationsController controller) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    if (item.isDelivery) {
      iconBg = const Color(0xFFE0F2FE);
      iconColor = const Color(0xFF0284C7);
      iconData = Icons.local_shipping_outlined;
    } else if (item.isVoucher) {
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      iconData = Icons.confirmation_number_outlined;
    } else if (item.isPromo) {
      iconBg = const Color(0xFFFFE4E6);
      iconColor = const Color(0xFFE11D48);
      iconData = Icons.bolt_rounded;
    } else {
      iconBg = const Color(0xFFEEF2FF);
      iconColor = const Color(0xFF4F46E5);
      iconData = Icons.info_outline_rounded;
    }

    final dateStr = DateFormat('d MMM, HH:mm').format(item.createdAt);

    return InkWell(
      onTap: () {
        Get.back();
        controller.handleNotificationTap(item);
      },
      borderRadius: AppSpacing.roundedLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.03),
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(
            color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: iconBg, borderRadius: AppSpacing.roundedMd),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(dateStr, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(item.body, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
