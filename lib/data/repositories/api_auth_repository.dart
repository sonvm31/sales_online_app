import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio = DioClient().dio;
  final String loginPath;
  final String registerPath;

  ApiAuthRepository({
    this.loginPath = '/auth/login',
    this.registerPath = '/auth/register',
  });

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

      return _sessionFromResponse(response.data, fallbackEmail: email);
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        registerPath,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'role': 'BUYER',
        },
      );

      return _sessionFromResponse(response.data, fallbackEmail: email);
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  AuthSession _sessionFromResponse(
    Map<String, dynamic>? responseData, {
    required String fallbackEmail,
  }) {
    final body = responseData ?? const <String, dynamic>{};
    final nestedData = body['data'];
    final data = nestedData is Map<String, dynamic> ? nestedData : body;
    final token = data['accessToken'] ?? data['token'] ?? data['idToken'];

    if (token is! String || token.isEmpty) {
      throw const AuthException('Phản hồi không chứa access token.');
    }

    return AuthSession(
      accessToken: token,
      email: (data['email'] as String?) ?? fallbackEmail,
    );
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] ?? data['error']
        : null;

    return message is String && message.isNotEmpty
        ? message
        : 'Không thể kết nối đến máy chủ.';
  }
}