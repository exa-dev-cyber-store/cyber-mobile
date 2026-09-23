import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../routes/app_pages.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderHistoryController orderController = Get.find<OrderHistoryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order History', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => orderController.getOrders(),
        child: GetBuilder<OrderHistoryController>(
          init: orderController,
          builder: (controller) {
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.orders.isEmpty) {
              return EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'No Orders Yet',
                description: 'You have not placed any orders yet. Start shopping!',
                buttonText: 'Start Shopping',
                onButtonPressed: () => Get.offNamed(Routes.HOME),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: controller.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedXl,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Date & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                DateFormatter.formatShort(order.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              StatusBadge(status: order.statusDelivery),
                              const SizedBox(width: 6),
                              StatusBadge(status: order.statusPayment),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Order Items Summary
                      if (order.orderItems.isNotEmpty) ...[
                        Text(
                          order.orderItems.first.name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.orderItems.length > 1
                              ? '${order.orderItems.first.quantity} item • +${order.orderItems.length - 1} other item(s)'
                              : '${order.orderItems.first.quantity} item',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),

                      // Footer: Price & Invoice Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Amount', style: AppTextStyles.bodySmall),
                              Text(
                                CurrencyFormatter.format(order.total),
                                style: AppTextStyles.price.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => Get.toNamed('/invoice/${order.id}'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedPill),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: Text(
                                  'Invoice',
                                  style: AppTextStyles.labelSmall,
                                ),
                              ),
                              if (order.statusPayment.toLowerCase() == 'pending') ...[
                                const SizedBox(width: AppSpacing.sm),
                                ElevatedButton(
                                  onPressed: () => controller.payPendingOrder(order),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.textLight,
                                    minimumSize: const Size(80, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedPill),
                                  ),
                                  child: Text(
                                    'Pay',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
