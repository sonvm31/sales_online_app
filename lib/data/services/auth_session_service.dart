import 'package:sales_online_app/data/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _emailKey = 'auth_email';

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final email = prefs.getString(_emailKey);

    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return AuthSession(accessToken: token, email: email);
  }

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessTokenKey, session.accessToken),
      prefs.setString(_emailKey, session.email),
    ]);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.remove(_accessTokenKey), prefs.remove(_emailKey)]);
  }
}
