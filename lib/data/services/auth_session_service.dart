import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService {
  static const String _userIdKey = 'auth_user_id';
  static const String _accessTokenKey = 'auth_access_token';
  static const String _firebaseUidKey = 'auth_firebase_uid';
  static const String _fullNameKey = 'auth_full_name';
  static const String _emailKey = 'auth_email';
  static const String _phoneKey = 'auth_phone';
  static const String _roleKey = 'auth_role';

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final firebaseUid = prefs.getString(_firebaseUidKey);
    final email = prefs.getString(_emailKey);

    if (token == null ||
        token.isEmpty ||
        firebaseUid == null ||
        firebaseUid.isEmpty ||
        email == null ||
        email.isEmpty) {
      return null;
    }

    return AuthSession(
      userId: prefs.getInt(_userIdKey),
      accessToken: token,
      firebaseUid: firebaseUid,
      fullName: prefs.getString(_fullNameKey),
      email: email,
      phone: prefs.getString(_phoneKey),
      role: prefs.getString(_roleKey) ?? 'BUYER',
    );
  }

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      if (session.userId == null)
        prefs.remove(_userIdKey)
      else
        prefs.setInt(_userIdKey, session.userId!),
      prefs.setString(_accessTokenKey, session.accessToken),
      prefs.setString(_firebaseUidKey, session.firebaseUid),
      prefs.setString(_emailKey, session.email),
      prefs.setString(_roleKey, session.role),
      if (session.fullName == null)
        prefs.remove(_fullNameKey)
      else
        prefs.setString(_fullNameKey, session.fullName!),
      if (session.phone == null)
        prefs.remove(_phoneKey)
      else
        prefs.setString(_phoneKey, session.phone!),
    ]);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_userIdKey),
      prefs.remove(_accessTokenKey),
      prefs.remove(_firebaseUidKey),
      prefs.remove(_fullNameKey),
      prefs.remove(_emailKey),
      prefs.remove(_phoneKey),
      prefs.remove(_roleKey),
    ]);
  }
}
