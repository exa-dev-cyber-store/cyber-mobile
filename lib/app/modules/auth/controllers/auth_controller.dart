import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';

class AuthController extends GetxController {
  late final AuthRepository _authRepo;

  final isLoading = false.obs;
  final isObscuredPassword = true.obs;
  final isObscuredConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepo = AuthRepository(LocalStorageService.instance);
  }

  void togglePasswordVisibility() {
    isObscuredPassword.value = !isObscuredPassword.value;
  }

  void toggleConfirmVisibility() {
    isObscuredConfirm.value = !isObscuredConfirm.value;
  }

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      AppSnackbar.warning(
        'Email dan password tidak boleh kosong',
        title: 'Perhatian',
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authRepo.login(
        email: email.trim(),
        password: password,
      );

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
        title: 'Gagal Masuk',
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
        'Semua bidang wajib diisi',
        title: 'Perhatian',
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

      if (result['token'] != null) {
        AppSnackbar.success(
          'Selamat datang di Cyber Store! Silakan masuk.',
          title: 'Pendaftaran Berhasil',
        );
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      AppLogger.e('Registration failed', e);
      AppSnackbar.error(
        e,
        title: 'Gagal Mendaftar',
      );
    } finally {
      isLoading.value = false;
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
        title: 'Google Sign-In Gagal',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
