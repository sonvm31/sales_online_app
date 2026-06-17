import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/product_model.dart';

class ProductService {
  final Dio _dio;

  ProductService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Map<String, dynamic>> fetchProducts({
    required int page,
    int size = 10,
    int? categoryId,
  }) async {
    try {
      final String url = categoryId == null
          ? '/products'
          : '/products/category/$categoryId';

      final Map<String, dynamic> queryParams = {'page': page, 'size': size};

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _dio.get(url, queryParameters: queryParams);

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

  Future<Map<String, dynamic>> searchProducts({
    String? keyword,
    int? categoryId,
    int? shopId,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'id',
    String sortDirection = 'asc',
    required int page,
    int size = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      };

      if (keyword != null && keyword.trim().isNotEmpty) {
        queryParams['keyword'] = keyword.trim();
      }
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      if (shopId != null) {
        queryParams['shopId'] = shopId;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      final response = await _dio.get(
        '/products/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        final List<dynamic> content = responseData['content'] ?? [];
        final List<ProductModel> productList = content
            .map((json) => ProductModel.fromJson(json))
            .toList();
        final bool isLastPage = responseData['last'] ?? true;

        return {
          'products': productList,
          'isLast': isLastPage
        };
      } else {
        throw Exception('Lỗi kết nối API Search: ${response.statusCode}');
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
