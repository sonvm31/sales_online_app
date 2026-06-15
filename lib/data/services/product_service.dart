import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        final List<dynamic> content = responseData['content'] ?? [];
        final List<ProductModel> productList = content
            .map((json) => ProductModel.fromJson(json))
            .toList();

        final bool isLastPage = responseData['last'] ?? true;

        return {'products': productList, 'isLast': isLastPage};
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể lấy danh sách sản phẩm: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi kết nối máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tìm kiếm sản phẩm: $e');
    }
  }

  Future<ProductModel> fetchProductDetail(int productId) async {
    try {
      final response = await _dio.get('/products/$productId');

      if (response.statusCode == 200 && response.data is Map) {
        return ProductModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể lấy thông tin sản phẩm: $e');
    }
  }
}
