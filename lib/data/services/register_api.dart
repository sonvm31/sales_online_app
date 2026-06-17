import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sales_online_app/core/network/dio_client.dart';
import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class RegisterApi {
  static const String _usersSyncPath = '/users/sync';

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  RegisterApi({Dio? dio, FirebaseAuth? firebaseAuth})
    : _dio = dio ?? DioClient().dio,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedFullName = fullName.trim();

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthException('Không thể tạo tài khoản.');
      }

      if (normalizedFullName.isNotEmpty) {
        await user.updateDisplayName(normalizedFullName);
      }

      final session = await _syncUser(
        firebaseUid: user.uid,
        email: normalizedEmail,
        fullName: normalizedFullName,
      );
      await user.sendEmailVerification();

      return session;
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
    final userId = data['id'];

    if ((email is! String || email.isEmpty) && fallbackEmail.isEmpty) {
      throw const AuthException('Phản hồi không chứa email người dùng.');
    }

    return AuthSession(
      userId: _parseUserId(userId),
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

  int? _parseUserId(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
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
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'operation-not-allowed':
        return 'Email/password chưa được bật trong Firebase.';
      case 'network-request-failed':
        return 'Không thể kết nối Firebase. Vui lòng thử lại.';
      default:
        return error.message ?? 'Có lỗi xảy ra khi tạo tài khoản.';
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
