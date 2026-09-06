import 'address_model.dart';

class OrderItemModel {
  final String id;
  final String name;
  final int price;
  final int quantity;
  final String? image;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        if (image != null) 'image': image,
      };
}

class OrderModel {
  final String id;
  final String user;
  final int total;
  final int tax;
  final int shipping;
  final int discount;
  final String statusPayment;
  final String statusDelivery;
  final String? paymentMethod;
  final String? token;
  final String? urlRedirect;
  final AddressModel? deliveryAddress;
  final List<OrderItemModel> orderItems;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.user,
    required this.total,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.statusPayment,
    required this.statusDelivery,
    this.paymentMethod,
    this.token,
    this.urlRedirect,
    this.deliveryAddress,
    required this.orderItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    AddressModel? address;
    if (json['delivery_address'] is Map<String, dynamic>) {
      address = AddressModel.fromJson(json['delivery_address']);
    }

    List<OrderItemModel> items = [];
    if (json['order_items'] is List) {
      items = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      user: json['user'] is Map ? (json['user']['name'] ?? '') : (json['user']?.toString() ?? ''),
      total: (json['total'] as num?)?.toInt() ?? 0,
      tax: (json['tax'] as num?)?.toInt() ?? 0,
      shipping: (json['shipping'] as num?)?.toInt() ?? 0,
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      statusPayment: json['status_payment']?.toString() ?? 'pending',
      statusDelivery: json['status_delivery']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString(),
      token: json['token']?.toString(),
      urlRedirect: json['url_redirect']?.toString(),
      deliveryAddress: address,
      orderItems: items,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
