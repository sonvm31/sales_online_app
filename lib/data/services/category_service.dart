import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/category_model.dart';

class CategoryService {
  final _dio = DioClient().dio;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi phản hồi hệ thống: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }
}
