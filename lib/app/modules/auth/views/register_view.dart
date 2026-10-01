import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create New Account',
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign up to start shopping for your favorite Apple devices',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.roundedXl,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'e.g. John Doe',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 20),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
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
                        const SizedBox(height: AppSpacing.lg),
                        Obx(
                          () => AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'At least 8 characters',
                            isPassword: controller.isObscuredPassword.value,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Obx(
                          () => AppTextField(
                            controller: _passwordConfirmController,
                            label: 'Confirm Password',
                            hint: 'Repeat password',
                            isPassword: controller.isObscuredConfirm.value,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Obx(
                          () => AppButton(
                            text: 'Sign Up',
                            isLoading: controller.isLoading.value,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller.register(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'or sign up with',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Apple Sign-Up Button
                  Obx(
                    () => AppButton(
                      text: 'Sign up with Apple',
                      variant: AppButtonVariant.primary,
                      prefixIcon: const Icon(Icons.apple, color: Colors.white, size: 22),
                      isLoading: controller.isLoading.value,
                      onPressed: () => controller.loginWithApple(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Google Sign-Up Button
                  AppButton(
                    text: 'Continue with Google',
                    variant: AppButtonVariant.outline,
                    prefixIcon: Image.asset(
                      'assets/icons/google_icn.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 22),
                    ),
                    onPressed: () => controller.loginWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Back to login footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      InkWell(
                        onTap: () => Get.offNamed(Routes.LOGIN),
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
