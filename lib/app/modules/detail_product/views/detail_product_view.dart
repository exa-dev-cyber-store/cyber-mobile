import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/widget/card_product_widget.dart';
import '../controllers/detail_product_controller.dart';
import '../widgets/detail_product_skeleton.dart';

class DetailProductView extends StatelessWidget {
  DetailProductView({super.key});

  final DetailProductController controller = Get.find<DetailProductController>();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Product Details', style: AppTextStyles.titleSmall),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
            onPressed: () => Get.toNamed(Routes.CART),
          ),
        ],
      ),
      body: GetBuilder<DetailProductController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const DetailProductSkeleton();
          }

          final product = ctrl.product;
          if (product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Product Not Found',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'The product may have been removed or is unavailable.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: 'Back',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Product Image Viewer
                Container(
                  width: double.infinity,
                  height: 320,
                  color: AppColors.surface,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: AppImage(
                        imageUrl: ctrl.activeImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Multi-Angle Image Thumbnails
                if (ctrl.allImages.length > 1)
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ctrl.allImages.map((img) {
                            final isSelected = ctrl.activeImage == img;
                            return GestureDetector(
                              onTap: () => ctrl.setActiveImage(img),
                              child: Container(
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSecondary,
                                  borderRadius: AppSpacing.roundedMd,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: AppImage(
                                  imageUrl: img,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Product Title, Price & Highlights Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      if (product.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accent,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),

                      // Name
                      Text(
                        product.name,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Price
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Highlights Badges
                      Row(
                        children: [
                          _buildBadge(Icons.verified_rounded, '1-Year Warranty'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildBadge(Icons.local_shipping_outlined, 'Free Shipping'),
                          const SizedBox(width: AppSpacing.sm),
                          _buildBadge(Icons.security_rounded, '100% Authentic'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Description Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Description', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.md),
                      ReadMoreText(
                        product.description.isEmpty ? 'No description available.' : product.description,
                        trimLines: 4,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Read more',
                        trimExpandedText: ' Show less',
                        moreStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.accent),
                        lessStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.accent),
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Related Products Section
                if (ctrl.relatedProducts.isNotEmpty && homeController != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Related Products', style: AppTextStyles.titleSmall),
                        const SizedBox(height: AppSpacing.lg),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: ctrl.relatedProducts.length,
                          itemBuilder: (context, index) {
                            final related = ctrl.relatedProducts[index];
                            final isLiked = homeController.isProductLiked(related.id);
                            return CardProductWidget(
                              id: related.id,
                              imageThumbnail: related.imageThumbnail,
                              name: related.name,
                              price: related.price,
                              category: related.category,
                              like: isLiked,
                              homeController: homeController,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),

      // Sticky Bottom CTA Bar
      bottomNavigationBar: GetBuilder<DetailProductController>(
        builder: (ctrl) {
          if (ctrl.isLoading) return const DetailProductBottomBarSkeleton();
          if (ctrl.product == null) return const SizedBox.shrink();

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
              child: Row(
                children: [
                  // Total price display
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit Price', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(ctrl.product!.price),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Add to cart button
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      text: 'Add to Cart',
                      prefixIcon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: AppColors.textLight),
                      isLoading: ctrl.isAddingToCart,
                      onPressed: () => ctrl.addToCart(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceTertiary,
          borderRadius: AppSpacing.roundedSm,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
