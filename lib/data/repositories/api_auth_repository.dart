import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio = DioClient().dio;
  final String loginPath;

  ApiAuthRepository({this.loginPath = '/auth/login'});

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        loginPath,
        data: {'email': email, 'password': password},
      );
      final responseData = response.data ?? const <String, dynamic>{};
      final nestedData = responseData['data'];
      final data = nestedData is Map<String, dynamic>
          ? nestedData
          : responseData;
      final token = data['accessToken'] ?? data['token'] ?? data['idToken'];

      if (token is! String || token.isEmpty) {
        throw const AuthException(
          'Phản hồi đăng nhập không chứa access token.',
        );
      }

      return AuthSession(
        accessToken: token,
        email: (data['email'] as String?) ?? email,
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message'] ?? data['error']
          : null;

      throw AuthException(
        message is String && message.isNotEmpty
            ? message
            : 'Không thể kết nối đến máy chủ.',
      );
    }
  }
}
