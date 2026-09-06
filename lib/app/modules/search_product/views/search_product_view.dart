import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/widget/card_product_widget.dart';
import '../controllers/search_product_controller.dart';
import '../widgets/skelaton_products_search_widget.dart';

class SearchProductView extends StatelessWidget {
  SearchProductView({super.key});

  final SearchProductController controller = Get.isRegistered<SearchProductController>()
      ? Get.find<SearchProductController>()
      : Get.put(SearchProductController());

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
        title: Hero(
          tag: 'searchField',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: controller.textController,
              autofocus: true,
              style: AppTextStyles.bodyLarge,
              onChanged: controller.onQueryChanged,
              onSubmitted: controller.performSearch,
              decoration: InputDecoration(
                hintText: 'Cari produk Apple...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
            ),
          ),
        ),
        actions: [
          GetBuilder<SearchProductController>(
            builder: (ctrl) => ctrl.textController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: ctrl.clearSearch,
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Pills
            GetBuilder<SearchProductController>(
              builder: (ctrl) {
                if (ctrl.categories.isEmpty) return const SizedBox();
                return SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ctrl.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final cat = ctrl.categories[index];
                      final isSelected = ctrl.selectedCategory == cat;
                      return Material(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.roundedPill,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: AppSpacing.roundedPill,
                          onTap: () => ctrl.selectCategory(cat),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            child: Center(
                              child: Text(
                                cat,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search Results Section
            GetBuilder<SearchProductController>(
              builder: (ctrl) {
                if (ctrl.isLoading) {
                  return const SkelatonProductsSearchWidget();
                }

                if (ctrl.textController.text.isEmpty && ctrl.results.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_rounded,
                    title: 'Cari Produk Impian Anda',
                    description: 'Ketik nama perangkat seperti iPhone, MacBook, atau iPad.',
                  );
                }

                if (ctrl.results.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'Produk Tidak Ditemukan',
                    description: 'Coba kata kunci lain atau periksa ejaan pencarian Anda.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ditemukan ${ctrl.totalFound} produk',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: ctrl.results.length,
                      itemBuilder: (context, index) {
                        final product = ctrl.results[index];
                        final isLiked = homeController?.isProductLiked(product.id) ?? false;
                        return CardProductWidget(
                          id: product.id,
                          imageThumbnail: product.imageThumbnail,
                          name: product.name,
                          price: product.price,
                          category: product.category,
                          like: isLiked,
                          homeController: homeController ?? Get.put(HomeController()),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
