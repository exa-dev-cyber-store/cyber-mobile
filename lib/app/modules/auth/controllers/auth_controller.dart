import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';

class AuthController extends GetxController {
  late final AuthRepository _authRepo;

  final isLoading = false.obs;
  final isVerifying = false.obs;
  final isResending = false.obs;
  final resendCooldown = 60.obs;
  final isObscuredPassword = true.obs;
  final isObscuredConfirm = true.obs;
  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    _authRepo = AuthRepository(LocalStorageService.instance);
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isObscuredPassword.value = !isObscuredPassword.value;
  }

  void toggleConfirmVisibility() {
    isObscuredConfirm.value = !isObscuredConfirm.value;
  }

  void startCooldownTimer() {
    _cooldownTimer?.cancel();
    resendCooldown.value = 60;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      AppSnackbar.warning(
        'Email and password cannot be empty.',
        title: 'Attention',
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authRepo.login(
        email: email.trim(),
        password: password,
      );

      if (result['requiresEmailVerification'] == true) {
        AppSnackbar.warning(
          'Please verify your email address before signing in.',
          title: 'Verification Required',
        );
        startCooldownTimer();
        Get.toNamed(Routes.VERIFY_EMAIL, arguments: {'email': email.trim()});
        return;
      }

      if (result['token'] != null) {
        AppLogger.s('Login successful for $email');
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController(), permanent: true);
        } else {
          Get.find<HomeController>().onInit();
        }
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      AppLogger.e('Login failed', e);
      AppSnackbar.error(
        e,
        title: 'Login Failed',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      AppSnackbar.warning(
        'All fields are required.',
        title: 'Attention',
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authRepo.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      if (result['requiresEmailVerification'] == true) {
        AppSnackbar.success(
          'Account created! A 6-digit verification code has been sent to your email.',
          title: 'Verification Code Sent',
        );
        startCooldownTimer();
        Get.toNamed(Routes.VERIFY_EMAIL, arguments: {'email': email.trim()});
        return;
      }

      if (result['token'] != null) {
        AppSnackbar.success(
          'Welcome to Cyber Store! Please sign in.',
          title: 'Registration Successful',
        );
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      AppLogger.e('Registration failed', e);
      AppSnackbar.error(
        e,
        title: 'Registration Failed',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    if (code.trim().length != 6) {
      AppSnackbar.warning(
        'Please enter a complete 6-digit verification code.',
        title: 'Attention',
      );
      return false;
    }

    try {
      isVerifying.value = true;
      final result = await _authRepo.verifyEmail(
        email: email.trim(),
        code: code.trim(),
      );

      if (result['token'] != null) {
        AppSnackbar.success(
          'Email verified successfully! Welcome to Cyber Store.',
          title: 'Verification Success',
        );
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController(), permanent: true);
        } else {
          Get.find<HomeController>().onInit();
        }
        Get.offAllNamed(Routes.HOME);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Email verification failed', e);
      AppSnackbar.error(
        e,
        title: 'Verification Failed',
      );
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendVerification({required String email}) async {
    if (resendCooldown.value > 0 || isResending.value) return;

    try {
      isResending.value = true;
      await _authRepo.resendVerificationCode(email: email.trim());
      startCooldownTimer();
      AppSnackbar.success(
        'A new 6-digit verification code has been sent to your email.',
        title: 'Code Sent',
      );
    } catch (e) {
      AppLogger.e('Resend verification code failed', e);
      AppSnackbar.error(
        e,
        title: 'Resend Failed',
      );
    } finally {
      isResending.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final account = await _authRepo.signInWithGoogleAccount();
      if (account == null) {
        isLoading.value = false;
        return;
      }

      final result = await _authRepo.loginWithGoogleApi(email: account.email);
      if (result['token'] != null) {
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController(), permanent: true);
        } else {
          Get.find<HomeController>().onInit();
        }
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.toNamed(Routes.REGISTER);
      }
    } catch (e) {
      AppLogger.e('Google sign-in error', e);
      AppSnackbar.error(
        e,
        title: 'Google Sign-In Failed',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      final credential = await _authRepo.signInWithAppleAccount();
      if (credential == null) {
        isLoading.value = false;
        return;
      }

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        AppSnackbar.error(
          'Failed to obtain Apple identity credentials. Please try again.',
          title: 'Apple Sign-In Failed',
        );
        isLoading.value = false;
        return;
      }

      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [credential.givenName, credential.familyName]
            .where((p) => p != null && p.isNotEmpty)
            .join(' ');
      }

      final result = await _authRepo.loginWithAppleApi(
        identityToken: identityToken,
        email: credential.email,
        name: fullName,
      );

      if (result['token'] != null) {
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController(), permanent: true);
        } else {
          Get.find<HomeController>().onInit();
        }
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.toNamed(Routes.REGISTER);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.e('Apple sign-in authorization error: ${e.code} - ${e.message}', e);
      if (e.code != AuthorizationErrorCode.canceled) {
        AppSnackbar.error(
          e.message.isNotEmpty
              ? e.message
              : 'Apple Sign-In failed (Code: ${e.code}). Please ensure an Apple ID is signed in under device Settings.',
          title: 'Apple Sign-In Failed',
        );
      }
    } catch (e) {
      AppLogger.e('Apple sign-in error', e);
      AppSnackbar.error(
        e,
        title: 'Apple Sign-In Failed',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
