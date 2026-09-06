import 'address_model.dart';
import 'order_model.dart';
import 'user_model.dart';

class InvoiceModel {
  final UserModel user;
  final AddressModel deliveryAddress;
  final OrderModel order;
  final int total;
  final int tax;
  final int shipping;
  final int discount;
  final String statusPayment;
  final String statusDelivery;
  final String? paymentMethod;

  InvoiceModel({
    required this.user,
    required this.deliveryAddress,
    required this.order,
    required this.total,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.statusPayment,
    required this.statusDelivery,
    this.paymentMethod,
  });

  int get subtotal => total - tax - shipping + discount;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      deliveryAddress: AddressModel.fromJson(json['delivery_address'] as Map<String, dynamic>),
      order: OrderModel.fromJson(json['order'] as Map<String, dynamic>),
      total: (json['total'] as num?)?.toInt() ?? 0,
      tax: (json['tax'] as num?)?.toInt() ?? 0,
      shipping: (json['shipping'] as num?)?.toInt() ?? 0,
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      statusPayment: json['status_payment']?.toString() ?? 'pending',
      statusDelivery: json['status_delivery']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString(),
    );
  }
}
