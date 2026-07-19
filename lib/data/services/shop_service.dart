import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/product_model.dart';

class ShopService {
  final Dio _dio;

  ShopService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<ShopModel> fetchShopByOwner(int userId) async {
    try {
      final response = await _dio.get('/shops/owner/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return _parseShop(data);
        }
        if (data is Map) {
          return _parseShop(Map<String, dynamic>.from(data));
        }
      }

      throw Exception('Lỗi máy chủ: ${response.statusCode}');
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    } catch (e) {
      throw Exception('Không thể lấy thông tin shop. Vui lòng thử lại.');
    }
  }

  Future<void> registerShop({
    required int userId,
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String avatarUrl,
  }) async {
    try {
      await _dio.post(
        '/shops/register',
        data: <String, dynamic>{
          'userId': userId,
          'name': name,
          'description': description,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'avatarUrl': avatarUrl,
        },
      );
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể gửi đăng ký shop. Vui lòng thử lại.');
    }
  }

  ShopModel _parseShop(Map<String, dynamic> data) {
    final rawShop = data['data'] ?? data['shop'] ?? data;
    if (rawShop is Map<String, dynamic>) {
      return ShopModel.fromJson(rawShop);
    }
    if (rawShop is Map) {
      return ShopModel.fromJson(Map<String, dynamic>.from(rawShop));
    }
    return ShopModel.fromJson(data);
  }

  String _messageFromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    if (statusCode == 404) {
      return 'Tài khoản này chưa có shop.';
    }
    if (statusCode == 403) {
      return 'Bạn không có quyền truy cập shop này.';
    }
    if (statusCode == null) {
      return 'Không thể kết nối máy chủ.';
    }

    return 'Không thể xử lý yêu cầu shop ($statusCode).';
  }
}
