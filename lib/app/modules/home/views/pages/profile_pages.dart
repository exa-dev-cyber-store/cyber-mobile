import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cyber/core/constants/app_colors.dart';
import 'package:cyber/core/constants/app_spacing.dart';
import 'package:cyber/core/constants/app_text_styles.dart';
import 'package:cyber/core/utils/app_snackbar.dart';
import 'package:cyber/app/routes/app_pages.dart';
import 'package:cyber/app/modules/home/controllers/home_controller.dart';

class ProfilePages extends StatelessWidget {
  ProfilePages({super.key});

  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil Saya', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // User Header Card
            GetBuilder<HomeController>(
              builder: (controller) => Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedXl,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with gradient initials
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          controller.userName.isNotEmpty
                              ? controller.userName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.userName,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.userEmail,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.roundedPill,
                            ),
                            child: Text(
                              'CYBER MEMBER',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Section 1: Shopping Activity
            _buildSectionHeader('Aktivitas Belanja'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedXl,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Lacak status pesanan dan invoice',
                    onTap: () => Get.toNamed(Routes.ORDER_HISTORY),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Buku Alamat',
                    subtitle: 'Kelola alamat tujuan pengiriman',
                    onTap: () => Get.toNamed(Routes.ADDRESS),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 2: General Info
            _buildSectionHeader('Informasi & Bantuan'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedXl,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Garansi Resmi Apple',
                    subtitle: 'Informasi klaim garansi & perbaikan',
                    onTap: () {
                      AppSnackbar.info('Semua unit produk bergaransi resmi 1 tahun.', title: 'Garansi Resmi');
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Cyber Store',
                    subtitle: 'Versi 1.0.2 - Premium Apple Experience',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 3: Logout
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedXl,
                border: Border.all(color: AppColors.border),
              ),
              child: _buildMenuItem(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                title: 'Keluar Akun',
                titleColor: AppColors.error,
                subtitle: 'Hapus sesi login dari perangkat ini',
                showArrow: false,
                onTap: () => _confirmLogout(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
        child: Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    required String subtitle,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.08),
          borderRadius: AppSpacing.roundedMd,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(color: titleColor ?? AppColors.textPrimary),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: showArrow
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20)
          : null,
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Konfirmasi Keluar', style: AppTextStyles.titleMedium),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Anda?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              homeController.logout();
            },
            child: Text(
              'Keluar',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
