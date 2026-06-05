import 'package:dio/dio.dart';
import 'package:sales_online_app/data/models/category_model.dart';

class CategoryService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<List<CategoryModel>> fetchCategories() async{
    try{
      final response = await _dio.get('/categories');
      if (response.statusCode == 200){
        final List<dynamic> data = response.data;

        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }else{
        throw Exception('Lỗi phản hồi hệ thống: ${response.statusCode}');
      }
    }on DioException catch (e){
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }
}
