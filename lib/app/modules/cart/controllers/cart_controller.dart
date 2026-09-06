import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/cart_model.dart';
import '../../../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = CartRepository();

  List<CartItemModel> products = [];
  int totalCart = 0;
  bool isLoading = false;
  bool isUpdatingItem = false;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  void calculateTotalCart() {
    totalCart = products.fold(
      0,
      (previousValue, item) => previousValue + (item.product.price * item.quantity),
    );
    update();
  }

  Future<void> fetchCart() async {
    isLoading = true;
    update();

    try {
      products = await _cartRepo.getCart();
      calculateTotalCart();
    } catch (e) {
      AppLogger.e('Error fetching cart', e);
      products = [];
      totalCart = 0;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addToCart({required String id}) async {
    isUpdatingItem = true;
    update();

    try {
      final success = await _cartRepo.addToCart(productId: id, quantity: 1);
      if (success) {
        final existingIndex = products.indexWhere((item) => item.product.id == id);
        if (existingIndex != -1) {
          products[existingIndex].quantity += 1;
        } else {
          await fetchCart();
          return;
        }
        calculateTotalCart();
      }
    } catch (e) {
      AppLogger.e('Error incrementing cart quantity', e);
      AppSnackbar.error('Tidak dapat menambah jumlah produk.', title: 'Gagal');
    } finally {
      isUpdatingItem = false;
      update();
    }
  }

  Future<void> reduceCart({required String id}) async {
    isUpdatingItem = true;
    update();

    try {
      final success = await _cartRepo.reduceCart(productId: id);
      if (success) {
        final existingIndex = products.indexWhere((item) => item.product.id == id);
        if (existingIndex != -1) {
          if (products[existingIndex].quantity > 1) {
            products[existingIndex].quantity -= 1;
          } else {
            products.removeAt(existingIndex);
          }
        }
        calculateTotalCart();
      }
    } catch (e) {
      AppLogger.e('Error reducing cart quantity', e);
      AppSnackbar.error('Tidak dapat mengurangi jumlah produk.', title: 'Gagal');
    } finally {
      isUpdatingItem = false;
      update();
    }
  }

  Future<void> deleteCart({required String id}) async {
    try {
      final success = await _cartRepo.removeFromCart(productId: id);
      if (success) {
        products.removeWhere((item) => item.product.id == id);
        calculateTotalCart();
        AppSnackbar.info('Produk dihapus dari keranjang belanja.', title: 'Dihapus');
      }
    } catch (e) {
      AppLogger.e('Error deleting item from cart', e);
      AppSnackbar.error('Gagal menghapus produk dari keranjang.', title: 'Gagal');
    }
  }

  void clearCart() {
    products.clear();
    totalCart = 0;
    update();
  }
}
