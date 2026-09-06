class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/signin';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Products
  static const String products = '/api/products';
  static String productDetail(String id) => '/api/products/$id';

  // Categories
  static const String categories = '/api/categories';

  // Cart
  static const String cart = '/api/carts';

  // Likes / Wishlist
  static const String likes = '/api/likes';

  // Orders
  static const String orders = '/api/orders';
  static const String orderCharge = '/api/orders/charge';
  static String orderStatus(String id) => '/api/orders/$id/status';

  // Invoices
  static String invoice(String id) => '/api/invoices/$id';

  // Delivery Addresses
  static const String deliveryAddresses = '/api/delivery-addresses';
  static String deliveryAddressDetail(String id) => '/api/delivery-addresses/$id';

  // Vouchers
  static const String publicVouchers = '/api/vouchers/public';
  static const String validateVoucher = '/api/vouchers/validate';

  // Wilayah Indonesia (External API)
  static const String wilayahBaseUrl = 'https://exa31.github.io/api-wilayah-indonesia/api';
  static const String provinces = '$wilayahBaseUrl/provinces.json';
  static String regencies(String provinceId) => '$wilayahBaseUrl/regencies/$provinceId.json';
  static String districts(String regencyId) => '$wilayahBaseUrl/districts/$regencyId.json';
  static String villages(String districtId) => '$wilayahBaseUrl/villages/$districtId.json';
}
