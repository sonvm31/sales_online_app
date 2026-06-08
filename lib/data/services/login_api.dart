import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class LoginApi {
  static const String _usersSyncPath = '/users/sync';

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  LoginApi({Dio? dio, FirebaseAuth? firebaseAuth})
    : _dio = dio ?? DioClient().dio,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthException('Không thể xác thực tài khoản.');
      }

      return _syncUser(
        firebaseUid: user.uid,
        email: normalizedEmail,
        fullName: user.displayName,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFromFirebase(error));
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  Future<AuthSession> _syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? phone,
    String role = 'BUYER',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _usersSyncPath,
      data: <String, dynamic>{
        'firebaseUid': firebaseUid,
        'fullName': _resolveFullName(fullName, email),
        'email': email,
        'phone': phone ?? '',
        'role': role,
      },
    );

    return _sessionFromResponse(
      response.data,
      fallbackEmail: email,
      fallbackFirebaseUid: firebaseUid,
    );
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
      accessToken:
          (data['accessToken'] ?? data['token'] ?? data['idToken'])
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

  String _resolveFullName(String? fullName, String email) {
    final trimmedName = fullName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    return email.split('@').first;
  }

  String _messageFromFirebase(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không đúng định dạng.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'network-request-failed':
        return 'Không thể kết nối Firebase. Vui lòng thử lại.';
      default:
        return error.message ?? 'Có lỗi xảy ra khi xác thực.';
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] ?? data['error']
        : null;

    return message is String && message.isNotEmpty
        ? message
        : 'Không thể đồng bộ tài khoản với máy chủ.';
  }
}
