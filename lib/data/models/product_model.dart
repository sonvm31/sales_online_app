import 'package:sales_online_app/data/models/category_model.dart';

class ProductModel {
  final int id;
  final ShopModel shop;
  final CategoryModel category;
  final ProductLineModel productLine;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.shop,
    required this.category,
    required this.productLine,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
  });

  String get shopName => shop.name;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final shopData = _asMap(json['shop']);
    final categoryData = _asMap(json['category']);
    final productLineData = _asMap(json['productLine']);

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      shop: ShopModel.fromJson(shopData),
      category: CategoryModel.fromJson(categoryData),
      productLine: ProductLineModel.fromJson(productLineData),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      imageUrl: (json['imageUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shop.toJson(),
      'category': category.toJson(),
      'productLine': productLine.toJson(),
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
    };
  }
}

class ShopModel {
  final int id;
  final String name;
  final String description;
  final String avatarUrl;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final String? address;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.isActive,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Chưa rõ shop',
      description: (json['description'] as String?) ?? '',
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 10.841200,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.809900,
      address: (json['address'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
    };
  }
}

class ProductLineModel {
  final int id;
  final CategoryModel category;
  final String name;
  final String description;

  const ProductLineModel({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
  });

  factory ProductLineModel.fromJson(Map<String, dynamic> json) {
    return ProductLineModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      category: CategoryModel.fromJson(_asMap(json['category'])),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      'name': name,
      'description': description,
    };
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
