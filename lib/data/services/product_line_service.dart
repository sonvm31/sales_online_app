import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/product_model.dart';

class ProductLineService {
  final Dio _dio;

  ProductLineService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<List<ProductLineModel>> fetchProductLines() async {
    try {
      final response = await _dio.get('/product-lines');

      if (response.statusCode == 200) {
        final dynamic data = response.data;

        if (data is List) {
          return data
              .whereType<Map>()
              .map(
                (json) =>
                    ProductLineModel.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();
        }

        if (data is Map<String, dynamic>) {
          final dynamic rawItems =
              data['data'] ?? data['content'] ?? data['productLines'];

          if (rawItems is List) {
            return rawItems
                .whereType<Map>()
                .map(
                  (json) => ProductLineModel.fromJson(
                    Map<String, dynamic>.from(json),
                  ),
                )
                .toList();
          }
        }

        return <ProductLineModel>[];
      }

      throw Exception('Lỗi phản hồi hệ thống: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }
}
