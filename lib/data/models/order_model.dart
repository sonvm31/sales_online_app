import 'package:sales_online_app/data/models/product_model.dart';

class OrderUserModel {
  final int id;
  final String firebaseUid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  const OrderUserModel({
    required this.id,
    required this.firebaseUid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory OrderUserModel.fromJson(Map<String, dynamic> json) {
    return OrderUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firebaseUid: (json['firebaseUid'] as String?) ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
    );
  }
}

class OrderItemModel {
  final int id;
  final ProductModel product;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      product: ProductModel.fromJson(_asMap(json['product'])),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderModel {
  final int id;
  final OrderUserModel user;
  final double totalAmount;
  final String status;
  final String address;
  final String paymentMethod;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final List<OrderItemModel> orderItems;
  final double shippingFee;

  const OrderModel({
    required this.id,
    required this.user,
    required this.totalAmount,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.orderItems,
    required this.shippingFee,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['orderItems'];
    final items = <OrderItemModel>[];

    if (itemsRaw is List) {
      for (final item in itemsRaw.whereType<Map>()) {
        items.add(OrderItemModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: OrderUserModel.fromJson(_asMap(json['user'])),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      paymentMethod: (json['paymentMethod'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
      orderItems: items,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
