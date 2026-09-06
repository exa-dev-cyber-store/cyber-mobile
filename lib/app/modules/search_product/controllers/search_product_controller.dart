import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';

class SearchProductController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  final TextEditingController textController = TextEditingController();
  CancelToken? _cancelToken;
  Timer? _debounceTimer;

  List<ProductModel> results = [];
  List<String> categories = [];
  String selectedCategory = '';
  bool isLoading = false;
  int totalFound = 0;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    textController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    try {
      final list = await _categoryRepo.getCategories();
      categories = list.map((c) => c.name).toList();
      update();
    } catch (e) {
      AppLogger.e('Error loading search categories', e);
    }
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      results.clear();
      totalFound = 0;
      update();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      performSearch(query.trim());
    });
  }

  void selectCategory(String cat) {
    if (selectedCategory == cat) {
      selectedCategory = '';
    } else {
      selectedCategory = cat;
    }
    update();
    if (textController.text.trim().isNotEmpty) {
      performSearch(textController.text.trim());
    }
  }

  Future<void> performSearch(String query) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    isLoading = true;
    update();

    try {
      final response = await _productRepo.getProducts(
        q: query,
        category: selectedCategory,
        limit: 20,
        cancelToken: _cancelToken,
      );

      results = response.items;
      totalFound = response.total;
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        AppLogger.e('Search error', e);
      }
    } catch (e) {
      AppLogger.e('Search error', e);
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearSearch() {
    textController.clear();
    results.clear();
    totalFound = 0;
    update();
  }
}
