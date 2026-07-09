import 'package:firebase_auth/firebase_auth.dart';
import 'package:sales_online_app/data/repositories/auth_repository.dart';

class PasswordResetApi {
  static const String _resetLinkUrl =
      'https://onlinesalessystem-663f4.firebaseapp.com/password-reset';
  static const String _androidPackageName = 'com.sales_online.sales_online_app';
  static const String _iOSBundleId = 'com.salesonline.salesOnlineApp';

  final FirebaseAuth _firebaseAuth;

  PasswordResetApi({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: normalizedEmail,
        actionCodeSettings: ActionCodeSettings(
          url: _resetLinkUrl,
          handleCodeInApp: true,
          androidPackageName: _androidPackageName,
          iOSBundleId: _iOSBundleId,
        ),
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFromFirebase(error));
    }
  }

  Future<String> verifyPasswordResetCode({required String code}) async {
    try {
      return _firebaseAuth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFromFirebase(error));
    }
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFromFirebase(error));
    }
  }

  String _messageFromFirebase(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không đúng định dạng.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'expired-action-code':
        return 'Link đổi mật khẩu đã hết hạn. Vui lòng gửi lại link mới.';
      case 'invalid-action-code':
        return 'Link đổi mật khẩu không hợp lệ hoặc đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu.';
      case 'network-request-failed':
        return 'Không thể kết nối Firebase. Vui lòng thử lại.';
      case 'unauthorized-continue-uri':
        return 'Domain nhận link đổi mật khẩu chưa được cấp quyền trong Firebase.';
      default:
        return error.message ?? 'Không thể xử lý yêu cầu đổi mật khẩu.';
    }
  }
}
