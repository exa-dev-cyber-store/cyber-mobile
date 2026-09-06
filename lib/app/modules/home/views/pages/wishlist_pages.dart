import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cyber/core/constants/app_colors.dart';
import 'package:cyber/core/constants/app_spacing.dart';
import 'package:cyber/core/constants/app_text_styles.dart';
import 'package:cyber/core/widgets/empty_state_view.dart';
import 'package:cyber/app/modules/home/controllers/home_controller.dart';
import 'package:cyber/app/modules/home/widget/card_product_widget.dart';
import 'package:cyber/app/modules/home/widget/skeleton_products_like_widget.dart';

class WishlistPages extends StatelessWidget {
  const WishlistPages({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Wishlist Saya', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          GetBuilder<HomeController>(
            builder: (controller) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Text(
                  '${controller.listLikes.length} Item',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => homeController.fetchLikes(),
        child: GetBuilder<HomeController>(
          builder: (controller) {
            if (controller.isLoading && controller.listLikes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: SkeletonProductsLikeWidget(),
              );
            }

            if (controller.listLikes.isEmpty) {
              return EmptyStateView(
                icon: Icons.favorite_outline_rounded,
                title: 'Wishlist Masih Kosong',
                description: 'Simpan produk Apple favorit Anda di sini untuk dibeli nanti.',
                buttonText: 'Jelajahi Produk',
                onButtonPressed: () => controller.changePage(0),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
              ),
              itemCount: controller.listLikes.length,
              itemBuilder: (context, index) {
                final product = controller.listLikes[index];
                return CardProductWidget(
                  id: product.id,
                  imageThumbnail: product.imageThumbnail,
                  name: product.name,
                  price: product.price,
                  category: product.category,
                  like: true,
                  homeController: controller,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
