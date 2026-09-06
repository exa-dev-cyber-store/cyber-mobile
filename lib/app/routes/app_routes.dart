part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

class Routes {
  static const HOME = '/';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const STARTED = '/started';
  static const REGISTER = '/register';
  static const DETAIL_PRODUCT = '/detail-product/:id';
  static const CART = '/cart';
  static const ADDRESS = '/address';
  static const CREATE_ADDRESS = '/create-address';
  static const EDIT_ADDRESS = '/edit-address/:id';
  static const SELECT_ADDRESSES = '/select-addresses';
  static const CHECKOUT = '/checkout';
  static const SNAP_WEBVIEW = '/snap-webview';
  static const PAYMENT_DETAIL = '/payment-detail';
  static const ORDER_HISTORY = '/order-history';

  static const INVOICE = '/invoice/:id';
  static const SEARCH_PRODUCT = '/search-product';

  static String invoice(String id) => '/invoice/$id';
  static String detailProduct(String id) => '/detail-product/$id';
  static String editAddress(String id) => '/edit-address/$id';
}
