import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await controller.sendForgotPasswordEmail(email: _emailController.text);
      if (success && mounted) {
        setState(() {
          _submitted = true;
        });
        // Automatically redirect back to Login screen after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.offAllNamed(Routes.LOGIN),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _submitted ? AppColors.successBg : AppColors.accentLight,
                        borderRadius: AppSpacing.roundedXl,
                        border: Border.all(
                          color: (_submitted ? AppColors.success : AppColors.accent).withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_submitted ? AppColors.success : AppColors.accent).withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _submitted ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                        color: _submitted ? AppColors.success : AppColors.accent,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title & Description
                  Text(
                    _submitted ? 'Check Your Email' : 'Forgot Password',
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _submitted
                        ? 'Password reset link has been dispatched. Redirecting to sign in...'
                        : 'Enter your registered email address to receive a secure password reset link',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Apple Relay Info Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.apple_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Sign in with Apple users can enter their Apple Private Relay address (...@privaterelay.appleid.com).',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedXl,
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_submitted) ...[
                                AppButton(
                                  text: 'Back to Sign In',
                                  onPressed: () => Get.offAllNamed(Routes.LOGIN),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AppButton(
                                  text: 'Resend Reset Link',
                                  variant: AppButtonVariant.outline,
                                  isLoading: controller.isLoading.value,
                                  onPressed: _handleSendResetLink,
                                ),
                              ] else ...[
                                AppButton(
                                  text: 'Send Reset Link',
                                  isLoading: controller.isLoading.value,
                                  onPressed: _handleSendResetLink,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Back to Login Link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Get.offAllNamed(Routes.LOGIN),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textSecondary),
                      label: Text(
                        'Back to Sign In',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
