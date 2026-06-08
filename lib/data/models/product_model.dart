class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String imageUrl;
  final String shopName;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
    required this.shopName
});

  factory ProductModel.fromJson(Map<String, dynamic> json){
    final shopData = json['shop'] as Map<String, dynamic>?;

    return ProductModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      stockQuantity: (json['stockQuantity'] as int?) ?? 0,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      shopName: shopData != null ? ((shopData['name'] as String?) ?? 'Chưa rõ shop') : 'Chưa rõ shop',
    );
  }
}