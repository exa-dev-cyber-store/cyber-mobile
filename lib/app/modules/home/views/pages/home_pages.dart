import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cyber/core/constants/app_colors.dart';
import 'package:cyber/core/constants/app_spacing.dart';
import 'package:cyber/core/constants/app_text_styles.dart';
import 'package:cyber/app/modules/cart/controllers/cart_controller.dart';
import 'package:cyber/app/routes/app_pages.dart';
import 'package:cyber/app/modules/home/controllers/home_controller.dart';
import 'package:cyber/app/modules/home/widget/bar_categories.widget.dart';
import 'package:cyber/app/modules/home/widget/card_product_widget.dart';
import 'package:cyber/app/modules/home/widget/skeleton_categories_widget.dart';
import 'package:cyber/app/modules/home/widget/skeleton_products_widget.dart';
import 'package:cyber/app/modules/home/widget/top_bar_search_widget.dart';
import 'package:cyber/app/modules/notifications/controllers/notifications_controller.dart';

class HomePages extends StatelessWidget {
  HomePages({super.key});

  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await homeController.fetchAll();
          },
          child: CustomScrollView(
            controller: homeController.scrollHome,
            slivers: [
              // Top Greeting & Cart Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GetBuilder<HomeController>(
                          builder: (controller) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${controller.userName.split(' ')[0]} 👋',
                                style: AppTextStyles.titleLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Welcome to Cyber Store',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notification Bell Button with dynamic badge
                          IconButton(
                            onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppSpacing.roundedMd,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.textPrimary,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Obx(() {
                                    if (!Get.isRegistered<NotificationsController>()) return const SizedBox.shrink();
                                    final count = Get.find<NotificationsController>().unreadCount.value;
                                    if (count == 0) return const SizedBox.shrink();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: AppSpacing.roundedPill,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                      child: Text(
                                        count > 9 ? '9+' : '$count',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textLight,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          // Cart Icon Button with dynamic badge
                          IconButton(
                            onPressed: () => Get.toNamed(Routes.CART),
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppSpacing.roundedMd,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: AppColors.textPrimary,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GetBuilder<CartController>(
                                    init: Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController()),
                                    builder: (cartCtrl) {
                                      if (cartCtrl.products.isEmpty) return const SizedBox();
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          cartCtrl.products.length.toString(),
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.textLight,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                  child: TopBarSearchWidget(),
                ),
              ),

              // Hero Promo Banner Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppSpacing.roundedXl,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.25),
                                  borderRadius: AppSpacing.roundedPill,
                                ),
                                child: Text(
                                  'OFFICIAL RESELLER',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.accent,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Complete Apple\nEcosystem',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textLight,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Official 1-Year Warranty',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.devices_other_rounded,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories Header & Scroller
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categories', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.md),
                      GetBuilder<HomeController>(
                        builder: (controller) => controller.isLoadingCategory
                            ? const SkeletonCategoriesWidget()
                            : BarCategoriesWidget(homeController: controller),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Title for Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetBuilder<HomeController>(
                        builder: (controller) => Text(
                          controller.activeCategory.isEmpty
                              ? 'Featured Products'
                              : 'Category: ${controller.activeCategory}',
                          style: AppTextStyles.titleSmall,
                        ),
                      ),
                      GetBuilder<HomeController>(
                        builder: (controller) => Text(
                          '${controller.totalProducts} Products',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products Grid or Skeleton
              GetBuilder<HomeController>(
                builder: (controller) {
                  if (controller.isLoading && controller.products.isEmpty) {
                    return const SkeletonProductsWidget();
                  }

                  if (controller.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No products found'),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = controller.products[index];
                          final isLiked = controller.isProductLiked(product.id);
                          return CardProductWidget(
                            id: product.id,
                            imageThumbnail: product.imageThumbnail,
                            name: product.name,
                            price: product.price,
                            category: product.category,
                            like: isLiked,
                            homeController: controller,
                          );
                        },
                        childCount: controller.products.length,
                      ),
                    ),
                  );
                },
              ),

              // Bottom Loading Indicator for Infinite Scroll
              SliverToBoxAdapter(
                child: GetBuilder<HomeController>(
                  builder: (controller) {
                    if (controller.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 80);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
