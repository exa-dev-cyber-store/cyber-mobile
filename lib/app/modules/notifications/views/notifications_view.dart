import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../data/models/notification_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final NotificationsController controller =
      Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isAuthenticated) {
        controller.fetchNotifications(isSilent: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (!controller.isAuthenticated) {
          return _buildUnauthenticatedView();
        }

        return Column(
          children: [
            _buildFilterChips(),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: _buildBody(),
            ),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Text(
            'Notifications',
            style:
                AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
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
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
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
      actions: [
        Obx(() {
          if (!controller.isAuthenticated ||
              controller.unreadCount.value == 0) {
            return const SizedBox.shrink();
          }
          return TextButton(
            onPressed: () => controller.markAllAsRead(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All', 'count': controller.notifications.length},
      {'key': 'orders', 'label': 'Orders', 'count': controller.ordersCount},
      {
        'key': 'vouchers',
        'label': 'Vouchers',
        'count': controller.vouchersCount
      },
      {'key': 'promos', 'label': 'Promos', 'count': controller.promosCount},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((filter) {
            final key = filter['key'] as String;
            final label = filter['label'] as String;
            final count = filter['count'] as int;
            final isSelected = controller.selectedFilter.value == key;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: InkWell(
                borderRadius: AppSpacing.roundedPill,
                onTap: () => controller.setFilter(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceSecondary,
                    borderRadius: AppSpacing.roundedPill,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppColors.surfaceTertiary,
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final items = controller.filteredNotifications;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final isLoadingMore = controller.isLoadingMore.value;
    final totalCount = items.length + (isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => controller.fetchNotifications(isSilent: true),
      child: ListView.separated(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: totalCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final item = items[index];
          return _buildNotificationCard(context, item);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    if (item.isDelivery) {
      iconBg = const Color(0xFFE0F2FE); // Light sky
      iconColor = const Color(0xFF0284C7); // Sky 600
      iconData = Icons.local_shipping_outlined;
    } else if (item.isVoucher) {
      iconBg = const Color(0xFFFEF3C7); // Amber 100
      iconColor = const Color(0xFFD97706); // Amber 600
      iconData = Icons.confirmation_number_outlined;
    } else if (item.isPromo) {
      iconBg = const Color(0xFFFFE4E6); // Rose 100
      iconColor = const Color(0xFFE11D48); // Rose 600
      iconData = Icons.bolt_rounded;
    } else {
      iconBg = const Color(0xFFEEF2FF); // Indigo 100
      iconColor = const Color(0xFF4F46E5); // Indigo 600
      iconData = Icons.info_outline_rounded;
    }

    final dateFormatted = DateFormat('d MMM, HH:mm').format(item.createdAt);

    return InkWell(
      onTap: () => controller.handleNotificationTap(item),
      borderRadius: AppSpacing.roundedLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.03),
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(
            color: item.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.35),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Type Icon Tile
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppSpacing.roundedMd,
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),

            // Main Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        dateFormatted,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  // Voucher Code Snippet Box
                  if (item.voucherCode != null &&
                      item.voucherCode!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB), // Amber 50
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(
                          color: const Color(0xFFFDE68A), // Amber 200
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.voucherCode!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF92400E), // Amber 800
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (item.discount != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE68A),
                                    borderRadius: AppSpacing.roundedSm,
                                  ),
                                  child: Text(
                                    '-${item.discount}%',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF78350F),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Obx(() {
                            final isCopied =
                                controller.copiedVoucherCode.value ==
                                    item.voucherCode;
                            return InkWell(
                              borderRadius: AppSpacing.roundedSm,
                              onTap: () =>
                                  controller.copyVoucherCode(item.voucherCode!),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCopied
                                          ? Icons.check_rounded
                                          : Icons.copy_rounded,
                                      size: 14,
                                      color: isCopied
                                          ? AppColors.success
                                          : const Color(0xFF92400E),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isCopied ? 'Copied' : 'Copy',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isCopied
                                            ? AppColors.success
                                            : const Color(0xFF92400E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // Delivery / Order Tracking Deep Link Button
                  if (item.isDelivery) ...[
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: () => Get.toNamed(Routes.ORDER_HISTORY),
                      borderRadius: AppSpacing.roundedSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Track Order Details',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Unread Dot
            if (!item.isRead) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String description;

    switch (controller.selectedFilter.value) {
      case 'orders':
        title = 'No Order Updates';
        description =
            'Shipping tracking alerts and status updates will appear here.';
        break;
      case 'vouchers':
        title = 'No Promo Vouchers';
        description =
            'Exclusive discount coupons and shopping vouchers will appear here.';
        break;
      case 'promos':
        title = 'No Promotions Right Now';
        description =
            'Special flash sales and new launch events will be posted here.';
        break;
      default:
        title = 'No Notifications Yet';
        description =
            'Stay tuned for order tracking updates, vouchers, and product releases.';
    }

    return EmptyStateView(
      icon: Icons.notifications_none_rounded,
      title: title,
      description: description,
      buttonText: 'Explore Store',
      onButtonPressed: () => Get.toNamed(Routes.HOME),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceTertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Sign In to View Notifications',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in to your Cyber Store account to track your orders, receive delivery alerts, and get exclusive promo vouchers.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              text: 'Sign In to Account',
              onPressed: () => Get.toNamed(Routes.LOGIN),
              width: 220,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
