import 'product_model.dart';

class CartItemModel {
  final String id;
  int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'quantity': quantity,
        'product': product.toJson(),
      };
}
