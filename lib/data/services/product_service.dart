import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/product_model.dart';

class ProductService {
  final _dio = DioClient().dio;

  Future<List<ProductModel>> fetchProducts() async {
    try{
      final response = await _dio.get('/products');

      if(response.statusCode == 200){
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    }catch (e){
      throw Exception('Không thể lấy danh sách sản phẩm: $e');
    }
  }
}