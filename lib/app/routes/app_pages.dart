import 'package:get/get.dart';

import '../modules/address/bindings/address_binding.dart';
import '../modules/address/views/address_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/started_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/create_address/bindings/create_address_binding.dart';
import '../modules/create_address/views/create_address_view.dart';
import '../modules/detail_product/bindings/detail_product_binding.dart';
import '../modules/detail_product/views/detail_product_view.dart';
import '../modules/edit_address/bindings/edit_address_binding.dart';
import '../modules/edit_address/views/edit_address_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/invoice_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/order_history/bindings/order_history_binding.dart';
import '../modules/order_history/views/order_history_view.dart';
import '../modules/search_product/bindings/search_product_binding.dart';
import '../modules/search_product/views/search_product_view.dart';
import '../modules/select_addresses/bindings/select_addresses_binding.dart';
import '../modules/select_addresses/views/select_addresses_view.dart';
import '../modules/payment_detail/bindings/payment_detail_binding.dart';
import '../modules/payment_detail/views/payment_detail_view.dart';
import '../modules/snap_webview/bindings/snap_webview_binding.dart';
import '../modules/snap_webview/views/snap_webview_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.STARTED;

  static final routes = [
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
        name: Routes.HOME,
        page: () => HomeView(),
        binding: HomeBinding(),
        children: [
          GetPage(
            name: Routes.DETAIL_PRODUCT,
            page: () => DetailProductView(),
            bindings: [
              DetailProductBinding(),
              HomeBinding(),
              CartBinding(),
            ],
          ),
        ]),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.STARTED,
      page: () => const StartedView(),
    ),
    GetPage(
      name: Routes.CART,
      page: () => CartView(),
      bindings: [
        CartBinding(),
        HomeBinding(),
      ],
    ),
    GetPage(
      name: Routes.ADDRESS,
      page: () => AddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: Routes.CREATE_ADDRESS,
      page: () => CreateAddressView(),
      bindings: [
        CreateAddressBinding(),
        AddressBinding(),
        SelectAddressesBinding(),
      ],
    ),
    GetPage(
      name: Routes.EDIT_ADDRESS,
      page: () => const EditAddressView(),
      binding: EditAddressBinding(),
    ),
    GetPage(
      name: Routes.SELECT_ADDRESSES,
      page: () => const SelectAddressesView(),
      bindings: [
        SelectAddressesBinding(),
        CartBinding(),
      ],
    ),
    GetPage(
      name: Routes.CHECKOUT,
      page: () => CheckoutView(),
      bindings: [
        CheckoutBinding(),
        CartBinding(),
        SelectAddressesBinding(),
      ],
    ),
    GetPage(
      name: Routes.SNAP_WEBVIEW,
      page: () => const SnapWebviewView(),
      binding: SnapWebviewBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_DETAIL,
      page: () => const PaymentDetailView(),
      binding: PaymentDetailBinding(),
    ),
    GetPage(
      name: Routes.ORDER_HISTORY,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),
    GetPage(
      name: Routes.INVOICE,
      page: () => const InvoiceView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: Routes.SEARCH_PRODUCT,
      page: () => SearchProductView(),
      bindings: [
        SearchProductBinding(),
        HomeBinding(),
      ],
    ),
  ];
}
