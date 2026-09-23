import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cart_controller.dart';
import '../widget/card_cart_products.dart';

class CartView extends GetView<CartController> {
  CartView({super.key});

  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Shopping Cart', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => cartController.fetchCart(),
        child: GetBuilder<CartController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.products.isEmpty) {
              return EmptyStateView(
                icon: Icons.shopping_bag_outlined,
                title: 'Your Cart is Empty',
                description: 'Find your dream Apple products and add them to your cart!',
                buttonText: 'Start Shopping',
                onButtonPressed: () => Get.offNamed(Routes.HOME),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: controller.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = controller.products[index];
                return CardCartproduct(
                  item: item,
                  controller: controller,
                );
              },
            );
          },
        ),
      ),

      // Sticky Checkout Bar
      bottomNavigationBar: GetBuilder<CartController>(
        builder: (controller) {
          if (controller.products.isEmpty) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Have a promo voucher? You can apply it at checkout.',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodyMedium),
                      Text(
                        CurrencyFormatter.format(controller.totalCart),
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Proceed to Checkout',
                    suffixIcon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textLight),
                    onPressed: () => Get.toNamed(Routes.CHECKOUT),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
