import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../routes/app_pages.dart';

class StartedView extends StatelessWidget {
  const StartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Mark Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apple_rounded, color: AppColors.textLight, size: 28),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'CYBER STORE',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textLight,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              // Hero Illustration
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppSpacing.roundedXl,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: AppSpacing.roundedXl,
                      child: Image.asset(
                        'assets/images/splash_logo2.png',
                        height: 220,
                        width: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.phone_iphone_rounded,
                          size: 140,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Inovasi Apple.\nKini di Tangan Anda.',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textLight,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Belanja produk Apple original dengan garansi resmi dan proteksi pembayaran terbaik.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AppButton(
                    text: 'Masuk ke Akun',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.toNamed(Routes.LOGIN),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Buat Akun Baru',
                    variant: AppButtonVariant.outline,
                    borderRadius: AppSpacing.roundedLg,
                    onPressed: () => Get.toNamed(Routes.REGISTER),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
