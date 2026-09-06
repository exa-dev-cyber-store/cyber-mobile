import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_like_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';
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

  // User Profile
  String userName = 'Member';
  String userEmail = '';

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
    await fetchAll();
  }

  void _setupScrollListener() {
    scrollHome.addListener(() {
      if (scrollHome.position.pixels >= scrollHome.position.maxScrollExtent - 200) {
        if (!isLoadingMore && products.length < totalProducts) {
          loadMoreProducts();
        }
      }
    });
  }

  void loadUserProfile() {
    userName = _storage.name ?? 'Member';
    userEmail = _storage.email ?? '';
    update();
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

  Future<void> logout() async {
    try {
      await _authRepo.logout();
      await Get.deleteAll(force: true);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      AppLogger.e('Logout error', e);
      AppSnackbar.error(
        'Terjadi masalah saat logout. Silakan coba lagi.',
        title: 'Gagal Keluar',
      );
    }
  }
}
