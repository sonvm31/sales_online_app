import 'package:dio/dio.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio = DioClient().dio;
  final String loginPath;
  final String registerPath;

  ApiAuthRepository({
    this.loginPath = '/users/sync',
    this.registerPath = '/users/sync',
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final firebaseUid = _fallbackFirebaseUid(normalizedEmail);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        loginPath,
        data: _syncPayload(
          email: normalizedEmail,
          firebaseUid: firebaseUid,
        ),
      );

      return _sessionFromResponse(
        response.data,
        fallbackEmail: normalizedEmail,
        fallbackFirebaseUid: firebaseUid,
      );
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
    final normalizedEmail = email.trim().toLowerCase();
    final firebaseUid = _fallbackFirebaseUid(normalizedEmail);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        registerPath,
        data: _syncPayload(
          email: normalizedEmail,
          firebaseUid: firebaseUid,
          fullName: fullName.trim(),
        ),
      );

      return _sessionFromResponse(
        response.data,
        fallbackEmail: normalizedEmail,
        fallbackFirebaseUid: firebaseUid,
      );
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  Map<String, dynamic> _syncPayload({
    required String email,
    required String firebaseUid,
    String? fullName,
    String? phone,
    String role = 'BUYER',
  }) {
    return <String, dynamic>{
      'firebaseUid': firebaseUid,
      'fullName': fullName ?? email.split('@').first,
      'email': email,
      'phone': phone ?? '',
      'role': role,
    };
  }

  AuthSession _sessionFromResponse(
    Map<String, dynamic>? responseData, {
    required String fallbackEmail,
    required String fallbackFirebaseUid,
  }) {
    final body = responseData ?? const <String, dynamic>{};
    final nestedData = body['data'];
    final data = nestedData is Map<String, dynamic> ? nestedData : body;
    final firebaseUid = data['firebaseUid'];
    final email = data['email'];

    if ((email is! String || email.isEmpty) && fallbackEmail.isEmpty) {
      throw const AuthException('Phản hồi không chứa email người dùng.');
    }

    return AuthSession(
      accessToken: (data['accessToken'] ?? data['token'] ?? data['idToken'])
              as String? ??
          fallbackFirebaseUid,
      firebaseUid: firebaseUid is String && firebaseUid.isNotEmpty
          ? firebaseUid
          : fallbackFirebaseUid,
      fullName: data['fullName'] as String?,
      email: email is String && email.isNotEmpty ? email : fallbackEmail,
      phone: data['phone'] as String?,
      role: (data['role'] as String?) ?? 'BUYER',
    );
  }

  String _fallbackFirebaseUid(String email) {
    return 'email:${email.trim().toLowerCase()}';
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
