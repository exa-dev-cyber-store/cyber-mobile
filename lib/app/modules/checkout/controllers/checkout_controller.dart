import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/voucher_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/voucher_repository.dart';
import '../../../routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../select_addresses/controllers/select_addresses_controller.dart';

class PaymentMethodOption {
  final String id;
  final String title;
  final String subtitle;
  final String paymentType;
  final String? bank;
  final IconData icon;

  const PaymentMethodOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.paymentType,
    this.bank,
    required this.icon,
  });
}

class CheckoutController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();
  final VoucherRepository _voucherRepo = VoucherRepository();

  int discount = 0;
  int total = 0;
  bool isCheckingOut = false;

  // Voucher states
  VoucherModel? appliedVoucher;
  List<VoucherModel> availableVouchers = [];
  bool isLoadingVouchers = false;
  bool isValidatingVoucher = false;
  String? voucherErrorMessage;

  late final CartController cartController;
  late final SelectAddressesController selectAddressController;

  int get subTotal => cartController.totalCart;
  int get tax => (subTotal * 0.05).round();
  int get shipping => subTotal > 5000000 ? 0 : 25000;

  final List<PaymentMethodOption> paymentMethods = const [
    PaymentMethodOption(
      id: 'bca',
      title: 'BCA Virtual Account',
      subtitle: 'Instant 24/7 automatic verification',
      paymentType: 'bank_transfer',
      bank: 'bca',
      icon: Icons.account_balance_rounded,
    ),
    PaymentMethodOption(
      id: 'mandiri',
      title: 'Mandiri Bill Payment',
      subtitle: 'Transfer via Livin by Mandiri or ATM',
      paymentType: 'bank_transfer',
      bank: 'mandiri',
      icon: Icons.account_balance_rounded,
    ),
    PaymentMethodOption(
      id: 'bni',
      title: 'BNI Virtual Account',
      subtitle: 'Transfer via BNI Mobile or ATM',
      paymentType: 'bank_transfer',
      bank: 'bni',
      icon: Icons.account_balance_rounded,
    ),
    PaymentMethodOption(
      id: 'bri',
      title: 'BRI Virtual Account (BRIVA)',
      subtitle: 'Transfer via BRImo or ATM',
      paymentType: 'bank_transfer',
      bank: 'bri',
      icon: Icons.account_balance_rounded,
    ),
    PaymentMethodOption(
      id: 'qris',
      title: 'QRIS (Gopay / OVO / Dana)',
      subtitle: 'Scan QR code with any e-Wallet or m-Banking app',
      paymentType: 'qris',
      icon: Icons.qr_code_2_rounded,
    ),
  ];

  late String selectedPaymentId;

  @override
  void onInit() {
    super.onInit();
    selectedPaymentId = paymentMethods.first.id;
    cartController = Get.find<CartController>();
    selectAddressController = Get.find<SelectAddressesController>();
    if (selectAddressController.addresses.isEmpty && !selectAddressController.isLoading) {
      selectAddressController.getAddress();
    }
    calculateTotal();
    fetchPublicVouchers();
  }

  void setPaymentMethod(String id) {
    selectedPaymentId = id;
    update();
  }

  PaymentMethodOption get selectedPaymentMethod {
    return paymentMethods.firstWhere(
      (m) => m.id == selectedPaymentId,
      orElse: () => paymentMethods.first,
    );
  }

  void calculateTotal() {
    final effectiveDiscount = discount.clamp(0, subTotal);
    total = (subTotal + tax + shipping - effectiveDiscount).clamp(0, 999999999999);
    update();
  }

  Future<void> fetchPublicVouchers() async {
    isLoadingVouchers = true;
    update();

    try {
      availableVouchers = await _voucherRepo.getPublicVouchers();
    } catch (e) {
      AppLogger.e('Error fetching public vouchers', e);
      availableVouchers = [];
    } finally {
      isLoadingVouchers = false;
      update();
    }
  }

  Future<bool> applyVoucherCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      voucherErrorMessage = 'Please enter a promo code first.';
      update();
      return false;
    }

    isValidatingVoucher = true;
    voucherErrorMessage = null;
    update();

    try {
      final res = await _voucherRepo.validateVoucher(
        code: cleanCode,
        subtotal: subTotal,
      );

      appliedVoucher = res.voucher;
      discount = res.discount;
      calculateTotal();

      AppSnackbar.success(
        'Voucher $cleanCode applied! Saved ${CurrencyFormatter.format(discount)}',
        title: 'Voucher Applied',
      );
      return true;
    } catch (e) {
      AppLogger.e('Error validating voucher', e);
      voucherErrorMessage = 'Invalid promo code or minimum spend requirement not met.';
      AppSnackbar.error(
        'Promo code "$cleanCode" is invalid or minimum spend requirement not met.',
        title: 'Failed to Apply Voucher',
      );
      return false;
    } finally {
      isValidatingVoucher = false;
      update();
    }
  }

  Future<void> applyVoucher(VoucherModel voucher) async {
    if (subTotal < voucher.minPurchase) {
      AppSnackbar.warning(
        'Minimum purchase for this voucher is ${CurrencyFormatter.format(voucher.minPurchase)}.',
        title: 'Minimum Spend Not Met',
      );
      return;
    }

    await applyVoucherCode(voucher.code);
  }

  void removeVoucher() {
    final code = appliedVoucher?.code ?? '';
    appliedVoucher = null;
    discount = 0;
    voucherErrorMessage = null;
    calculateTotal();

    if (code.isNotEmpty) {
      AppSnackbar.info('Voucher $code has been removed.', title: 'Voucher Removed');
    }
  }

  Future<void> checkout() async {
    var addressId = selectAddressController.currentAddressOption;
    if ((addressId == null || addressId.isEmpty) && selectAddressController.addresses.isNotEmpty) {
      addressId = selectAddressController.addresses.first.id;
      selectAddressController.selectAddress(addressId);
    }

    if (addressId == null || addressId.isEmpty) {
      AppSnackbar.warning(
        'Please select a delivery address first.',
        title: 'Address Not Selected',
      );
      Get.toNamed(Routes.SELECT_ADDRESSES);
      return;
    }

    if (cartController.products.isEmpty) {
      AppSnackbar.warning(
        'Your shopping cart is empty.',
        title: 'Cart is Empty',
      );
      return;
    }

    isCheckingOut = true;
    update();

    try {
      final method = selectedPaymentMethod;

      final chargeRes = await _orderRepo.chargeOrder(
        deliveryAddressId: addressId,
        paymentType: method.paymentType,
        bank: method.bank,
        discount: discount > 0 ? discount : null,
      );

      // Empty cart and navigate to native payment detail screen
      cartController.clearCart();
      Get.offNamed(
        Routes.PAYMENT_DETAIL,
        arguments: {
          'charge': chargeRes.charge,
          'orderId': chargeRes.orderId,
          'totalAmount': total,
        },
      );
    } catch (e) {
      AppLogger.e('Checkout charge error', e);
      AppSnackbar.error(
        'An error occurred while processing your order. Please try again.',
        title: 'Payment Processing Failed',
      );
    } finally {
      isCheckingOut = false;
      update();
    }
  }
}
