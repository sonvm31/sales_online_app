import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/seller_revenue_model.dart';

class SellerRevenueService {
  final Dio _dio;

  SellerRevenueService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<SellerRevenueModel> fetchRevenue(int shopId) async {
    try {
      final response = await _dio.get<dynamic>('/orders/shop/$shopId/revenue');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SellerRevenueModel.fromJson(data);
      }
      if (data is Map) {
        return SellerRevenueModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Dữ liệu doanh thu không hợp lệ.');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Không thể tải doanh thu shop.');
    }
  }
}
