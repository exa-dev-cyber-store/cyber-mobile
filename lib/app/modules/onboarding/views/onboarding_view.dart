import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  OnboardingView({super.key});

  final List<Map<String, String>> contents = [
    {
      'title': 'The Ultimate\nApple Experience',
      'image': 'assets/images/onboarding1.png',
      'description':
          'Discover the complete Apple ecosystem with official warranty. Unrivaled innovation right in your hands.',
    },
    {
      'title': 'Express &\nSecure Delivery',
      'image': 'assets/images/onboarding2.png',
      'description':
          'Express shipping with full insurance coverage delivered safely to your doorstep.',
    },
    {
      'title': 'Seamless &\nFlexible Payment',
      'image': 'assets/images/onboarding3.png',
      'description':
          'Integrated payments via Midtrans: QRIS, Bank Transfer, and flexible installments with data protection.',
    }
  ];

  final controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CYBER STORE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Obx(
                    () => controller.pagesIndex.value < 2
                        ? TextButton(
                            onPressed: () => Get.offNamed(Routes.LOGIN),
                            child: Text(
                              'Skip',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                itemCount: contents.length,
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.pagesIndex.value = index;
                },
                itemBuilder: (context, index) {
                  final item = contents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Container with subtle glow
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.devices_rounded,
                                size: 100,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Text content
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item['title']!,
                                style: AppTextStyles.displayMedium.copyWith(
                                  height: 1.15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                item['description']!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions & Page Indicators
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => Obx(
                        () {
                          final isSelected = controller.pagesIndex.value == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: AppSpacing.roundedPill,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Action Button
                  Obx(
                    () {
                      final isLastPage = controller.pagesIndex.value == contents.length - 1;
                      return AppButton(
                        text: isLastPage ? 'Get Started' : 'Continue',
                        suffixIcon: Icon(
                          isLastPage ? Icons.arrow_forward_rounded : Icons.chevron_right_rounded,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () {
                          if (isLastPage) {
                            Get.offNamed(Routes.LOGIN);
                          } else {
                            controller.nextPage();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
