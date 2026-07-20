import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/update_profile_request.dart';

class UserProfileService {
  final Dio _dio;

  UserProfileService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<void> updateProfile({
    required int userId,
    required UpdateProfileRequest request,
  }) async {
    try {
      await _dio.put<void>('/users/$userId/profile', data: request.toJson());
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 400) return 'Thông tin cập nhật không hợp lệ.';
    if (statusCode == 403) return 'Bạn không có quyền cập nhật hồ sơ này.';
    if (statusCode == 404) return 'Không tìm thấy tài khoản cần cập nhật.';
    return 'Không thể cập nhật hồ sơ. Vui lòng thử lại.';
  }
}
