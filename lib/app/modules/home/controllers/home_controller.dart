import 'dart:io' show File;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_like_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../data/services/fcm_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  late final AuthRepository _authRepo;
  late final LocalStorageService _storage;

  // Navigation index: 0 = Feed, 1 = Wishlist, 2 = Profile
  int indexPage = 0;

  // Products & Categories state
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  List<ProductLikeModel> listLikes = [];
  int totalProducts = 0;

  String activeCategory = '';
  bool isLoading = false;
  bool isLoadingCategory = false;
  bool isLoadingMore = false;

  // User Profile & Account Linking
  String userName = 'Member';
  String userEmail = '';
  String? userAvatar;
  Map<String, dynamic> linkedAccounts = {};
  bool isLoadingLinkedAccounts = false;
  bool isUploadingAvatar = false;
  bool isUpdatingProfile = false;

  // Controllers
  final ScrollController scrollHome = ScrollController();
  final TextEditingController searchController = TextEditingController();
  CancelToken cancelToken = CancelToken();

  @override
  void onInit() {
    super.onInit();
    _initServices();
    _setupScrollListener();
  }

  @override
  void onClose() {
    scrollHome.dispose();
    searchController.dispose();
    cancelToken.cancel();
    super.onClose();
  }

  Future<void> _initServices() async {
    _storage = await LocalStorageService.getInstance();
    _authRepo = AuthRepository(_storage);
    loadUserProfile();
    FcmService.syncTokenWithBackend();
    await fetchAll();
  }

  void _setupScrollListener() {
    scrollHome.addListener(() {
      if (scrollHome.position.pixels >=
          scrollHome.position.maxScrollExtent - 200) {
        if (!isLoadingMore && products.length < totalProducts) {
          loadMoreProducts();
        }
      }
    });
  }

  void loadUserProfile() {
    userName = _storage.name ?? 'Member';
    userEmail = _storage.email ?? '';
    userAvatar = _storage.avatar;
    update();
    fetchLinkedAccounts();
  }

  void changePage(int index) {
    indexPage = index;
    update();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    isLoadingCategory = true;
    update();

    try {
      await Future.wait([
        fetchCategories(),
        fetchProducts(),
        fetchLikes(),
      ]);
    } catch (e) {
      AppLogger.e('Error loading dashboard data', e);
    } finally {
      isLoading = false;
      isLoadingCategory = false;
      update();
    }
  }

  Future<void> fetchCategories() async {
    try {
      categories = await _categoryRepo.getCategories();
      update();
    } catch (e) {
      AppLogger.e('Error fetching categories', e);
    }
  }

  Future<void> fetchProducts() async {
    try {
      final result = await _productRepo.getProducts(
        limit: 8,
        skip: 0,
        category: activeCategory,
      );
      products = result.items;
      totalProducts = result.total;
      update();
    } catch (e) {
      AppLogger.e('Error fetching products', e);
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore || products.length >= totalProducts) return;

    isLoadingMore = true;
    update();

    try {
      final result = await _productRepo.getProducts(
        limit: 8,
        skip: products.length,
        category: activeCategory,
      );
      products.addAll(result.items);
      totalProducts = result.total;
    } catch (e) {
      AppLogger.e('Error loading more products', e);
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  void selectCategory(String name) {
    if (activeCategory == name) {
      activeCategory = '';
    } else {
      activeCategory = name;
    }
    isLoading = true;
    update();
    fetchProducts().whenComplete(() {
      isLoading = false;
      update();
    });
  }

  Future<void> fetchLikes() async {
    try {
      listLikes = await _productRepo.getLikes();
      update();
    } catch (e) {
      AppLogger.e('Error fetching wishlist', e);
    }
  }

  bool isProductLiked(String id) {
    return listLikes.any((p) => p.id == id);
  }

  Future<void> toggleLike(String id) async {
    try {
      final success = await _productRepo.toggleLike(id);
      if (success) {
        if (isProductLiked(id)) {
          listLikes.removeWhere((p) => p.id == id);
        } else {
          final matched = products.firstWhereOrNull((p) => p.id == id);
          if (matched != null) {
            listLikes.add(ProductLikeModel(
              id: matched.id,
              name: matched.name,
              price: matched.price,
              category: matched.category,
              description: matched.description,
              imageThumbnail: matched.imageThumbnail,
              imageDetails: matched.imageDetails,
            ));
          }
        }
        update();
      }
    } catch (e) {
      AppLogger.e('Error toggling like', e);
    }
  }

  Future<void> fetchLinkedAccounts() async {
    isLoadingLinkedAccounts = true;
    update();
    try {
      linkedAccounts = await _authRepo.getLinkedAccounts();
    } catch (e) {
      AppLogger.w('Failed to fetch linked accounts: $e');
    } finally {
      isLoadingLinkedAccounts = false;
      update();
    }
  }

  Future<bool> updateProfileName(String newName) async {
    if (newName.trim().isEmpty) return false;
    isUpdatingProfile = true;
    update();
    try {
      await _authRepo.updateProfileName(newName.trim());
      userName = newName.trim();
      AppSnackbar.success('Profile name updated successfully.',
          title: 'Success');
      update();
      return true;
    } catch (e) {
      AppLogger.e('Failed to update name', e);
      AppSnackbar.error(e, title: 'Failed to Update Name');
      return false;
    } finally {
      isUpdatingProfile = false;
      update();
    }
  }

  Future<void> pickCropAndUploadAvatar(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      // Circular crop using image_cropper
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      if (croppedFile == null) return;

      isUploadingAvatar = true;
      update();

      final newAvatarUrl = await _authRepo.uploadAvatar(File(croppedFile.path));
      if (newAvatarUrl != null) {
        userAvatar = newAvatarUrl;
        AppSnackbar.success('Profile picture updated successfully.',
            title: 'Success');
        update();
      }
    } catch (e) {
      AppLogger.e('Failed to upload avatar', e);
      AppSnackbar.error(e, title: 'Failed to Upload Photo');
    } finally {
      isUploadingAvatar = false;
      update();
    }
  }

  Future<void> bindGoogleAccount() async {
    try {
      final account = await _authRepo.signInWithGoogleAccount();
      if (account == null) return;

      final auth = await account.authentication;
      final token = auth.idToken ?? auth.accessToken;
      if (token == null) {
        AppSnackbar.error('Unable to retrieve Google credentials.',
            title: 'Connection Failed');
        return;
      }

      await _authRepo.linkGoogleApi(credential: token, email: account.email);
      userEmail = account.email;
      AppSnackbar.success('Google account connected successfully!',
          title: 'Success');
      await fetchLinkedAccounts();
    } catch (e) {
      AppLogger.e('Failed to link Google account', e);
      AppSnackbar.error(e, title: 'Failed to Connect Google');
    }
  }

  Future<void> bindAppleAccount() async {
    try {
      final credential = await _authRepo.signInWithAppleAccount();
      if (credential == null) return;

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        AppSnackbar.error('Unable to retrieve Apple credentials.',
            title: 'Connection Failed');
        return;
      }

      await _authRepo.linkAppleApi(
          identityToken: identityToken, email: credential.email);
      AppSnackbar.success('Apple account connected successfully!',
          title: 'Success');
      await fetchLinkedAccounts();
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.e(
          'Apple bind authorization error: ${e.code} - ${e.message}', e);
      if (e.code == AuthorizationErrorCode.canceled ||
          e.message.toLowerCase().contains('canceled') ||
          e.message.toLowerCase().contains('cancelled') ||
          e.message.contains('1001') ||
          e.toString().contains('1001')) {
        return;
      }
      AppSnackbar.error(
        'Unable to link Apple account. Please check your Apple ID settings or try again.',
        title: 'Failed to Connect Apple',
      );
    } catch (e) {
      AppLogger.e('Failed to link Apple account', e);
      final msg = e.toString().toLowerCase();
      if (msg.contains('canceled') || msg.contains('cancelled') || msg.contains('1001')) {
        return;
      }
      AppSnackbar.error(e, title: 'Failed to Connect Apple');
    }
  }

  Future<void> unbindAppleAccount() async {
    try {
      await _authRepo.unbindAppleApi();
      AppSnackbar.success('Apple account disconnected successfully!',
          title: 'Success');
      await fetchLinkedAccounts();
    } catch (e) {
      AppLogger.e('Failed to unbind Apple account', e);
      AppSnackbar.error(e, title: 'Failed to Disconnect Apple');
    }
  }

  Future<void> logout() async {
    try {
      await _authRepo.logout();
      await Get.deleteAll(force: true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      AppLogger.e('Logout error', e);
      AppSnackbar.error(
        'An issue occurred during logout. Please try again.',
        title: 'Logout Failed',
      );
    }
  }
}
