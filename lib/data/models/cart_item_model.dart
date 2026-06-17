import 'package:sales_online_app/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      product: ProductModel.fromJson(_asMap(json['product'])),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}
