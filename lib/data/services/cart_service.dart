import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/cart_item_model.dart';

class CartService {
  final Dio _dio;

  CartService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<CartItemModel>> fetchCart(int userId) async {
    final response = await _dio.get<List<dynamic>>('/cart/user/$userId');
    final data = response.data ?? const <dynamic>[];

    return data
        .whereType<Map>()
        .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    await _dio.post<void>(
      '/cart/add',
      queryParameters: <String, dynamic>{
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    await _dio.put<void>(
      '/cart/update/$cartItemId',
      queryParameters: <String, dynamic>{'quantity': quantity},
    );
  }

  Future<void> removeItem(int cartItemId) async {
    await _dio.delete<void>('/cart/remove/$cartItemId');
  }

  Future<void> clearCart(int userId) async {
    await _dio.delete<void>('/cart/clear/$userId');
  }
}
