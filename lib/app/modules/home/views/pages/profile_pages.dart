import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
        title: Text('My Profile', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    // Avatar with Photo / Initials & Edit Badge
                    Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: ClipOval(
                            child: controller.userAvatar != null &&
                                    controller.userAvatar!.isNotEmpty &&
                                    controller.userAvatar!.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: controller.userAvatar!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Center(
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
                                  )
                                : Center(
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
                        ),
                        if (controller.isUploadingAvatar)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => _showAvatarPickerSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  controller.userName,
                                  style: AppTextStyles.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _showEditNameDialog(context, controller.userName),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
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
            _buildSectionHeader('Shopping Activity'),
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.roundedXl,
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order History',
                    subtitle: 'Track order status and view invoices',
                    onTap: () => Get.toNamed(Routes.ORDER_HISTORY),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Address Book',
                    subtitle: 'Manage shipping and delivery addresses',
                    onTap: () => Get.toNamed(Routes.ADDRESS),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'View updates, shipping alerts, and vouchers',
                    onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 2: Linked Accounts
            _buildSectionHeader('Linked Accounts'),
            GetBuilder<HomeController>(
              builder: (controller) {
                final google = (controller.linkedAccounts['google'] is Map)
                    ? Map<String, dynamic>.from(controller.linkedAccounts['google'] as Map)
                    : <String, dynamic>{};
                final apple = (controller.linkedAccounts['apple'] is Map)
                    ? Map<String, dynamic>.from(controller.linkedAccounts['apple'] as Map)
                    : <String, dynamic>{};
                final signupProvider = controller.linkedAccounts['signupProvider']?.toString() ?? '';
                final isAppleSignup = controller.linkedAccounts['isAppleSignup'] == true || signupProvider == 'apple';
                final isGoogleSignup = signupProvider == 'google';

                final isGoogleLinked = google['linked'] == true || isGoogleSignup;
                final isAppleLinked = apple['linked'] == true || isAppleSignup;
                final canLinkGoogle = controller.linkedAccounts['canLinkGoogle'] == true;
                final canUnbindApple = controller.linkedAccounts['canUnbindApple'] == true || apple['canUnbind'] == true;
                final requiresGoogle = apple['requiresGoogleBeforeUnbind'] == true;
                final googleEmail = google['email']?.toString() ?? (isGoogleLinked ? controller.userEmail : '');
                final appleEmail = apple['email']?.toString() ?? (isAppleLinked ? controller.userEmail : '');

                return Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.roundedXl,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Google tile
                      _buildLinkedAccountTile(
                        icon: Image.asset(
                          'assets/icons/google_icn.png',
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
                        ),
                        title: 'Google',
                        subtitle: isGoogleLinked
                            ? (googleEmail.isNotEmpty ? googleEmail : (controller.userEmail.isNotEmpty ? controller.userEmail : 'Connected'))
                            : (canLinkGoogle ? 'Connect for faster sign-in' : 'Not linked to this account'),
                        actionWidget: isGoogleLinked
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: AppSpacing.roundedPill,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Connected',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (canLinkGoogle
                                ? GestureDetector(
                                    onTap: () => controller.bindGoogleAccount(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.accent),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Connect',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceTertiary,
                                      borderRadius: AppSpacing.roundedPill,
                                    ),
                                    child: Text(
                                      'Not Linked',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textTertiary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  )),
                      ),
                      const Divider(height: 1, indent: 56),

                      // Apple tile
                      _buildLinkedAccountTile(
                        icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                        title: 'Apple',
                        subtitle: isAppleLinked
                            ? (appleEmail.isNotEmpty ? appleEmail : (controller.userEmail.isNotEmpty ? controller.userEmail : 'Connected'))
                            : 'Sign in securely with Apple',
                        actionWidget: isAppleLinked
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.successBg,
                                      borderRadius: AppSpacing.roundedPill,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Connected',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canUnbindApple) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _confirmUnbindApple(context, controller),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          'Disconnect',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : GestureDetector(
                                onTap: () => controller.bindAppleAccount(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Connect',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      if (isAppleLinked && requiresGoogle)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Connect a Google account first before disconnecting your Apple account.',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Section 3: General Info
            _buildSectionHeader('Information & Support'),
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.roundedXl,
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Official Apple Warranty',
                    subtitle: 'Warranty claims and official repairs',
                    onTap: () {
                      AppSnackbar.info('All product units include an official 1-year warranty.', title: 'Official Warranty');
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Cyber Store',
                    subtitle: 'Version 1.0.2 - Premium Apple Experience',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 4: Logout
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.roundedXl,
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildMenuItem(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                title: 'Log Out',
                titleColor: AppColors.error,
                subtitle: 'Sign out from this device',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.08),
                  borderRadius: AppSpacing.roundedMd,
                ),
                child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(color: titleColor ?? AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedAccountTile({
    required Widget icon,
    required String title,
    required String subtitle,
    required Widget actionWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          actionWidget,
        ],
      ),
    );
  }

  void _showAvatarPickerSheet(BuildContext context) {
    Get.bottomSheet(
      Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Update Profile Picture',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a photo to crop and set as your profile picture.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    homeController.pickCropAndUploadAvatar(ImageSource.camera);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text('Take Photo', style: AppTextStyles.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    homeController.pickCropAndUploadAvatar(ImageSource.gallery);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text('Choose from Gallery', style: AppTextStyles.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController nameInputController = TextEditingController(text: currentName);

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Edit Profile Name', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your new full name:',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameInputController,
              autofocus: true,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameInputController.text.trim();
              if (newName.isNotEmpty) {
                Get.back();
                await homeController.updateProfileName(newName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmUnbindApple(BuildContext context, HomeController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Disconnect Apple Account?', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to disconnect this Apple account? You can still sign in using your Google account.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.unbindAppleAccount();
            },
            child: Text(
              'Disconnect',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
        title: Text('Confirm Logout', style: AppTextStyles.titleMedium),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              homeController.logout();
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
