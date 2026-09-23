import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';

class DetailProductController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CartRepository _cartRepo = CartRepository();

  bool isLoading = true;
  bool isAddingToCart = false;
  String activeImage = '';
  ProductModel? product;
  List<ProductModel> relatedProducts = [];
  List<String> allImages = [];
  String productId = '';

  late final CartController cartController;

  @override
  void onInit() {
    super.onInit();
    productId = Get.parameters['id']?.toString() ?? '';
    cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    if (productId.isEmpty) return;

    isLoading = true;
    update();

    try {
      product = await _productRepo.getProductDetail(productId);
      if (product != null) {
        activeImage = product!.imageThumbnail;
        allImages = [product!.imageThumbnail, ...product!.imageDetails];

        // Fetch related products in the same category
        final related = await _productRepo.getProducts(
          limit: 4,
          category: product!.category,
        );
        relatedProducts =
            related.items.where((p) => p.id != productId).toList();
      }
    } catch (e) {
      AppLogger.e('Error loading product details', e);
      AppSnackbar.error('Unable to load product details.',
          title: 'Failed to Load');
    } finally {
      isLoading = false;
      update();
    }
  }

  void setActiveImage(String img) {
    activeImage = img;
    update();
  }

  Future<void> addToCart() async {
    if (product == null || isAddingToCart) return;

    isAddingToCart = true;
    update();

    try {
      final success =
          await _cartRepo.addToCart(productId: product!.id, quantity: 1);
      if (success) {
        await cartController.fetchCart();
        AppSnackbar.success(
          '${product!.name} has been added to your cart.',
          title: 'Added to Cart',
        );
      }
    } catch (e) {
      AppLogger.e('Error adding to cart', e);
      AppSnackbar.error('Failed to add product to cart.', title: 'Error');
    } finally {
      isAddingToCart = false;
      update();
    }
  }
}
